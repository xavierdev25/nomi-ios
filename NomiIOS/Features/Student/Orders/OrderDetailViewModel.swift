import Observation

/// Solo lectura: esta pantalla se abre para pedidos entregados o cancelados. Pagar o cancelar
/// un pedido activo se hace desde `OrderTrackingView`.
@MainActor
@Observable
final class OrderDetailViewModel {
    let orderId: Int
    private(set) var order: Order?
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let ordersAPI: OrdersAPI

    init(orderId: Int, ordersAPI: OrdersAPI) {
        self.orderId = orderId
        self.ordersAPI = ordersAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            order = try await ordersAPI.get(id: orderId)
            errorMessage = nil
        } catch is CancellationError {
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo cargar el pedido."
        }
    }
}
