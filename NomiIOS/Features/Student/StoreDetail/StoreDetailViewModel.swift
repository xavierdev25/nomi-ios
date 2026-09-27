import Observation

/// Carga en paralelo la tienda, sus productos disponibles y si es favorita.
@MainActor
@Observable
final class StoreDetailViewModel {
    let storeId: Int
    private(set) var store: Store?
    private(set) var products: [Product] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?
    private(set) var isFavorite = false
    private(set) var isTogglingFavorite = false

    private let storesAPI: StoresAPI
    private let productsAPI: ProductsAPI
    private let favoritesAPI: FavoritesAPI

    init(storeId: Int, storesAPI: StoresAPI, productsAPI: ProductsAPI, favoritesAPI: FavoritesAPI) {
        self.storeId = storeId
        self.storesAPI = storesAPI
        self.productsAPI = productsAPI
        self.favoritesAPI = favoritesAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            async let storeLoad = storesAPI.get(id: storeId)
            async let productsLoad = productsAPI.search(.init(storeId: storeId, disponible: true, size: 50))
            async let favoriteLoad = favoritesAPI.isStoreFavorite(storeId)
            let (fetchedStore, page, favorite) = try await (storeLoad, productsLoad, favoriteLoad)
            store = fetchedStore
            products = page.content
            isFavorite = favorite
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo cargar la tienda."
        }
    }

    /// Best effort: si falla, el corazón no cambia y no se muestra error.
    func toggleFavorite() async {
        guard !isTogglingFavorite else { return }
        isTogglingFavorite = true
        defer { isTogglingFavorite = false }
        do {
            if isFavorite {
                try await favoritesAPI.removeStore(storeId)
            } else {
                try await favoritesAPI.addStore(storeId)
            }
            isFavorite.toggle()
        } catch {
        }
    }
}
