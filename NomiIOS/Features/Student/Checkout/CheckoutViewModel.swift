import Foundation
import Observation

/// Fases del checkout. `failed` conserva el `orderId` cuando el pedido se creó pero el pago
/// no: reintentar paga ese mismo pedido en lugar de crear otro.
enum CheckoutPhase: Equatable {
    case idle
    case creatingOrder
    case creatingPayment(orderId: Int)
    case failed(message: String, orderId: Int?)
}

/// Confirma el pedido: elige salón y punto de encuentro, crea el pedido y obtiene la URL de
/// pago de MercadoPago.
@MainActor
@Observable
final class CheckoutViewModel {
    private(set) var aulas: [Aula] = []
    private(set) var isLoadingAulas = true
    private(set) var aulasError: String?

    var selectedAulaId: Int?
    var notas: String = ""
    var puntoEncuentro: String = "puerta"
    /// Salón del último pedido, fijado al crear la pantalla para que la insignia "Última usada"
    /// no siga a la selección actual.
    let lastUsedAulaId: Int?

    private(set) var phase: CheckoutPhase = .idle
    private(set) var completedOrderId: Int?

    private let ordersAPI: OrdersAPI
    private let paymentsAPI: PaymentsAPI
    private let aulasAPI: AulasAPI
    private let cartStore: CartStore

    /// Puntos de encuentro ofrecidos. El backend no tiene un campo para esto: se envía dentro de
    /// las notas del pedido.
    static let meetingPoints: [(value: String, label: String)] = [
        ("puerta", "La puerta del salón"),
        ("pasillo", "El pasillo"),
        ("entrada", "La entrada del edificio"),
        ("escaleras", "Las escaleras"),
        ("recepcion", "Recepción"),
    ]

    init(ordersAPI: OrdersAPI, paymentsAPI: PaymentsAPI, aulasAPI: AulasAPI, cartStore: CartStore) {
        self.ordersAPI = ordersAPI
        self.paymentsAPI = paymentsAPI
        self.aulasAPI = aulasAPI
        self.cartStore = cartStore
        self.selectedAulaId = cartStore.lastAulaId
        self.lastUsedAulaId = cartStore.lastAulaId
    }

    var isProcessing: Bool {
        switch phase {
        case .creatingOrder, .creatingPayment: true
        default: false
        }
    }

    var canPay: Bool {
        selectedAulaId != nil && !cartStore.items.isEmpty && !isProcessing
    }

    var subtotal: Decimal { cartStore.subtotal }
    /// Estimación previa al pago con `NMConstants`; el monto real lo calcula el backend.
    var total: Decimal { cartStore.subtotal + NMConstants.tarifaServicio + NMConstants.comisionNomi + cartStore.propina }

    func loadAulas() async {
        isLoadingAulas = true
        defer { isLoadingAulas = false }
        do {
            aulas = try await aulasAPI.activas()
            aulasError = nil
        } catch {
            aulasError = (error as? APIError)?.errorDescription ?? "No se pudieron cargar las aulas."
        }
    }

    /// Crea el pedido y obtiene la URL de pago.
    /// - Returns: la URL de MercadoPago, o `nil` con `phase = .failed`.
    func pay() async -> URL? {
        guard let aulaId = selectedAulaId, let storeId = cartStore.storeId else { return nil }
        phase = .creatingOrder
        do {
            let request = CreateOrderRequest(
                storeId: storeId,
                aulaId: aulaId,
                items: cartStore.items.map { .init(productId: $0.product.id, cantidad: $0.cantidad) },
                notas: combinedNotes(),
                propina: cartStore.propina > 0 ? cartStore.propina : nil
            )
            let order = try await ordersAPI.create(request)
            cartStore.setLastAulaId(aulaId)
            return await createPayment(orderId: order.id)
        } catch {
            phase = .failed(message: (error as? APIError)?.errorDescription ?? "No se pudo crear el pedido.", orderId: nil)
            return nil
        }
    }

    /// Reintenta solo el pago del pedido ya creado.
    func retryPayment() async -> URL? {
        guard case .failed(_, let orderId) = phase, let orderId else { return nil }
        return await createPayment(orderId: orderId)
    }

    /// Vacía el carrito en cuanto hay URL de pago: el pedido ya existe aunque el estudiante
    /// cierre MercadoPago sin pagar; puede pagarlo después desde el seguimiento.
    private func createPayment(orderId: Int) async -> URL? {
        phase = .creatingPayment(orderId: orderId)
        do {
            let url = try await paymentsAPI.checkoutURL(forOrder: orderId)
            cartStore.clear()
            completedOrderId = orderId
            phase = .idle
            return url
        } catch {
            let baseMessage = (error as? APIError)?.errorDescription ?? "No se pudo iniciar el pago."
            phase = .failed(message: "\(baseMessage) Tu pedido ya está registrado — puedes reintentar el pago.", orderId: orderId)
            return nil
        }
    }

    /// Une el punto de encuentro y las notas libres en el único campo `notas` del pedido.
    private func combinedNotes() -> String? {
        let meetingLabel = "Punto de encuentro: " + (Self.meetingPoints.first { $0.value == puntoEncuentro }?.label ?? "recepción").lowercased()
        let trimmed = notas.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? meetingLabel : "\(meetingLabel) | \(trimmed)"
    }
}
