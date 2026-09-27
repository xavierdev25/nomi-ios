import Observation

/// Datos de la pestaña de inicio: productos disponibles y recomendaciones, cargados en
/// paralelo. Un fallo de las recomendaciones no afecta a los productos.
@MainActor
@Observable
final class HomeViewModel {
    private(set) var products: [Product] = []
    private(set) var recommendations: [Recommendation] = []
    private(set) var isLoadingProducts = false
    private(set) var isLoadingRecommendations = false
    private(set) var errorMessage: String?

    private let productsAPI: ProductsAPI
    private let aiAPI: AiAPI

    init(productsAPI: ProductsAPI, aiAPI: AiAPI) {
        self.productsAPI = productsAPI
        self.aiAPI = aiAPI
    }

    func loadInitial() async {
        async let productsLoad: Void = loadProducts()
        async let recommendationsLoad: Void = loadRecommendations()
        _ = await (productsLoad, recommendationsLoad)
    }

    /// Corre en una tarea propia: SwiftUI cancela la tarea de `.refreshable` si la vista se
    /// actualiza durante la recarga, lo que abortaba peticiones ya respondidas.
    func refresh() async {
        await Task { await loadInitial() }.value
    }

    private func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        do {
            let page = try await productsAPI.search(.init(disponible: true, size: 20))
            products = page.content
            errorMessage = nil
        } catch is CancellationError {
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudieron cargar los productos."
        }
    }

    private func loadRecommendations() async {
        isLoadingRecommendations = true
        defer { isLoadingRecommendations = false }
        do {
            let response = try await aiAPI.getRecommendations(maxRecommendations: 5)
            recommendations = response.recommendations
        } catch is CancellationError {
        } catch {
            recommendations = []
        }
    }
}
