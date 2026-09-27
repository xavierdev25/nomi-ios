import SwiftUI

/// Punto de entrada. Crea el contenedor de dependencias una sola vez y publica
/// `AuthStore` y `CartStore` en el entorno de SwiftUI para que cualquier vista los observe.
///
/// La app fuerza el modo claro: la paleta (`NMColors`) solo está definida para fondo claro.
@main
struct NomiIOSApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootRouterView(container: container)
                .environment(container.authStore)
                .environment(container.cartStore)
                .preferredColorScheme(.light)
        }
    }
}
