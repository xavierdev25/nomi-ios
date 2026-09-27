import Observation

/// Carga los últimos 50 pedidos del usuario.
@MainActor
@Observable
final class OrdersListViewModel {
    private(set) var orders: [Order] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let ordersAPI: OrdersAPI

    init(ordersAPI: OrdersAPI) {
        self.ordersAPI = ordersAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let page = try await ordersAPI.me(page: 0, size: 50)
            orders = page.content.sorted { $0.id > $1.id }
            errorMessage = nil
        } catch is CancellationError {
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudieron cargar tus pedidos."
        }
    }

    /// Tarea propia para que la cancelación de `.refreshable` no aborte la recarga.
    func refresh() async {
        await Task { await load() }.value
    }
}
