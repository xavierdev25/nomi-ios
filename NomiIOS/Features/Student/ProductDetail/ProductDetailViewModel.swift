import Observation

/// Carga el producto y si es favorito, y alterna el favorito.
@MainActor
@Observable
final class ProductDetailViewModel {
    let productId: Int
    private(set) var product: Product?
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private(set) var isFavorite = false
    private(set) var isTogglingFavorite = false

    private let productsAPI: ProductsAPI
    private let favoritesAPI: FavoritesAPI

    init(productId: Int, productsAPI: ProductsAPI, favoritesAPI: FavoritesAPI) {
        self.productId = productId
        self.productsAPI = productsAPI
        self.favoritesAPI = favoritesAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let productLoad = productsAPI.get(id: productId)
            async let favoriteLoad = favoritesAPI.isProductFavorite(productId)
            let (fetchedProduct, favorite) = try await (productLoad, favoriteLoad)
            product = fetchedProduct
            isFavorite = favorite
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo cargar el producto."
        }
    }

    /// Best effort: si falla, el corazón no cambia y no se muestra error.
    func toggleFavorite() async {
        guard !isTogglingFavorite else { return }
        isTogglingFavorite = true
        defer { isTogglingFavorite = false }
        do {
            if isFavorite {
                try await favoritesAPI.removeProduct(productId)
            } else {
                try await favoritesAPI.addProduct(productId)
            }
            isFavorite.toggle()
        } catch {
        }
    }
}
