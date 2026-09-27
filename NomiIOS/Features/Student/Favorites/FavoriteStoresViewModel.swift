import Observation

/// Carga las tiendas favoritas.
@MainActor
@Observable
final class FavoriteStoresViewModel {
    private(set) var stores: [Store] = []
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
            stores = try await favoritesAPI.stores()
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudieron cargar tus tiendas favoritas."
        }
    }
}
