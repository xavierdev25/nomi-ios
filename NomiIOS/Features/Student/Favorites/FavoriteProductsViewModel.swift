import Observation

/// Carga y quita productos favoritos.
@MainActor
@Observable
final class FavoriteProductsViewModel {
    private(set) var products: [Product] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let favoritesAPI: FavoritesAPI

    init(favoritesAPI: FavoritesAPI) {
        self.favoritesAPI = favoritesAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await favoritesAPI.products()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudieron cargar tus favoritos."
        }
    }

    /// Optimista: lo quita de la lista antes de confirmar con el servidor.
    func remove(_ product: Product) async {
        products.removeAll { $0.id == product.id }
        try? await favoritesAPI.removeProduct(product.id)
    }
}
