import Foundation

/// Raíz de composición: el único lugar donde se instancian los tipos concretos de red y
/// estado y se conectan entre sí.
///
/// No es `@Observable` porque no tiene estado propio. Los stores se inyectan en el entorno;
/// las APIs se pasan explícitamente a cada `ViewModel` al construir la pantalla.
@MainActor
final class AppContainer {
    let authStore: AuthStore
    let cartStore: CartStore
    let productsAPI: ProductsAPI
    let aiAPI: AiAPI
    let ordersAPI: OrdersAPI
    let storesAPI: StoresAPI
    let paymentsAPI: PaymentsAPI
    let favoritesAPI: FavoritesAPI
    let aulasAPI: AulasAPI

    init() {
        let tokenStore = KeychainTokenStore()
        let refresher = TokenRefresher(tokenStore: tokenStore)
        let authStore = AuthStore(tokenStore: tokenStore)

        // `APIClient` necesita a `authStore` como `SessionExpiring` y `authStore` necesita un
        // `AuthAPI` construido sobre ese cliente: el ciclo se rompe asignando `authAPI` después,
        // antes de que ninguna vista pueda observar el store.
        let apiClient = APIClient(tokenStore: tokenStore, refresher: refresher, onSessionExpired: authStore)
        authStore.authAPI = AuthAPI(client: apiClient)

        self.authStore = authStore
        self.cartStore = CartStore()
        self.productsAPI = ProductsAPI(client: apiClient)
        self.aiAPI = AiAPI(client: apiClient)
        self.ordersAPI = OrdersAPI(client: apiClient)
        self.storesAPI = StoresAPI(client: apiClient)
        self.paymentsAPI = PaymentsAPI(client: apiClient)
        self.favoritesAPI = FavoritesAPI(client: apiClient)
        self.aulasAPI = AulasAPI(client: apiClient)
    }
}
