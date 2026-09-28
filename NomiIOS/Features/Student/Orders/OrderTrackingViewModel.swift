import Foundation
import Observation

/// Consulta el pedido cada 5 segundos hasta que llega a un estado final. El seguimiento es
/// por consulta periódica, no por WebSocket.
///
/// Es también el único lugar donde se puede actuar sobre un pedido sin pagar: antes, cerrar
/// MercadoPago sin pagar dejaba un pedido `PENDIENTE` (con stock reservado) sin forma de
/// pagarlo ni cancelarlo.
@MainActor
@Observable
final class OrderTrackingViewModel {
    let orderId: Int
    private(set) var order: Order?
    /// `nil` mientras el pedido no tiene pago (`GET /payments/order/{id}` responde 404).
    private(set) var payment: PaymentResponse?
    /// Cuándo vence el plazo para pagar, en el reloj del teléfono; `nil` si no hay plazo.
    private(set) var paymentDeadline: Date?
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private(set) var isPaying = false
    private(set) var isCancelling = false
    private(set) var actionError: String?

    private let ordersAPI: OrdersAPI
    private let paymentsAPI: PaymentsAPI
    private var pollingTask: Task<Void, Never>?

    init(orderId: Int, ordersAPI: OrdersAPI, paymentsAPI: PaymentsAPI) {
        self.orderId = orderId
        self.ordersAPI = ordersAPI
        self.paymentsAPI = paymentsAPI
    }

    /// Pendiente y sin pago aprobado. Con el pago ya aprobado no se ofrece cancelar: el backend
    /// pasaría el pedido a preparación en vez de cancelarlo (responde 409).
    var awaitingPayment: Bool {
        order?.status == .pendiente && payment?.isApproved != true
    }

    /// Si el plazo para pagar ya venció en `date`. El backend cancela el pedido en menos de un
    /// minuto; mientras tanto no tiene sentido abrir MercadoPago (rechazaría el pago).
    func isPaymentWindowClosed(at date: Date) -> Bool {
        guard let paymentDeadline else { return false }
        return date >= paymentDeadline
    }

    /// Plazo a mostrar tras una consulta. Cada consulta trae los segundos restantes redondeados
    /// y con la latencia de la red: si el plazo apenas cambió se conserva el anterior, para que
    /// la cuenta atrás no salte un segundo arriba y abajo cada 5 segundos.
    nonisolated static func stableDeadline(current: Date?, reported: Date?) -> Date? {
        guard let current, let reported, abs(reported.timeIntervalSince(current)) < 2 else {
            return reported
        }
        return current
    }

    /// Inicia la consulta periódica; no hace nada si ya está en marcha.
    func startTracking() {
        guard pollingTask == nil else { return }
        pollingTask = Task { [weak self] in
            while let self, !Task.isCancelled {
                await self.refresh()
                if let status = self.order?.status, status == .entregado || status == .cancelado {
                    return
                }
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }

    func stopTracking() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    /// - Returns: la URL de MercadoPago, o `nil` con `actionError`.
    func pay() async -> URL? {
        guard !isPaying else { return nil }
        isPaying = true
        actionError = nil
        defer { isPaying = false }
        do {
            return try await paymentsAPI.checkoutURL(forOrder: orderId)
        } catch is CancellationError {
            return nil
        } catch {
            actionError = (error as? APIError)?.errorDescription ?? "No se pudo iniciar el pago."
            return nil
        }
    }

    func cancel() async {
        guard !isCancelling else { return }
        isCancelling = true
        actionError = nil
        defer { isCancelling = false }
        do {
            let cancelled = try await ordersAPI.cancel(id: orderId, motivo: nil)
            order = cancelled
            paymentDeadline = cancelled.paymentDeadline(receivedAt: .now)
        } catch is CancellationError {
        } catch {
            actionError = (error as? APIError)?.errorDescription ?? "No se pudo cancelar el pedido."
        }
    }

    private func refresh() async {
        do {
            let fetched = try await ordersAPI.get(id: orderId)
            order = fetched
            paymentDeadline = Self.stableDeadline(current: paymentDeadline,
                                                  reported: fetched.paymentDeadline(receivedAt: .now))
            if fetched.status == .pendiente {
                do {
                    payment = try await paymentsAPI.byOrder(orderId: orderId)
                } catch APIError.server(_, statusCode: 404) {
                    payment = nil
                }
            }
            errorMessage = nil
        } catch is CancellationError {
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo actualizar el estado."
        }
        isLoading = false
    }
}
