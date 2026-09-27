import SwiftUI

/// Un único `NavigationStack` que envuelve la barra de pestañas: cualquier pantalla se apila
/// encima de la pestaña activa, en lugar de tener una pila por pestaña.
struct StudentRootView: View {
    let container: AppContainer
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            StudentTabView(container: container, path: $path)
                .navigationDestination(for: StudentRoute.self, destination: destinationView)
        }
    }

    /// Construye cada destino con su `ViewModel` y las APIs que necesita.
    @ViewBuilder
    private func destinationView(for route: StudentRoute) -> some View {
        switch route {
        case .productDetail(let id):
            ProductDetailView(
                viewModel: ProductDetailViewModel(productId: id, productsAPI: container.productsAPI, favoritesAPI: container.favoritesAPI),
                path: $path
            )
        case .storeDetail(let id):
            StoreDetailView(
                viewModel: StoreDetailViewModel(storeId: id, storesAPI: container.storesAPI, productsAPI: container.productsAPI, favoritesAPI: container.favoritesAPI),
                path: $path
            )
        case .cart:
            CartView(path: $path)
        case .checkout:
            CheckoutView(
                viewModel: CheckoutViewModel(ordersAPI: container.ordersAPI, paymentsAPI: container.paymentsAPI, aulasAPI: container.aulasAPI, cartStore: container.cartStore),
                path: $path
            )
        case .orderDetail(let id):
            OrderDetailView(viewModel: OrderDetailViewModel(orderId: id, ordersAPI: container.ordersAPI))
        case .orderTracking(let id):
            OrderTrackingView(viewModel: OrderTrackingViewModel(orderId: id, ordersAPI: container.ordersAPI, paymentsAPI: container.paymentsAPI))
        case .recommendations:
            RecommendationsView(viewModel: RecommendationsViewModel(aiAPI: container.aiAPI), path: $path)
        case .favoriteProducts:
            FavoriteProductsView(viewModel: FavoriteProductsViewModel(favoritesAPI: container.favoritesAPI), path: $path)
        case .favoriteStores:
            FavoriteStoresView(viewModel: FavoriteStoresViewModel(favoritesAPI: container.favoritesAPI), path: $path)
        }
    }
}
