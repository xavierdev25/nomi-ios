import SwiftUI

/// Decide la pantalla raíz: verificación de sesión en curso, app del estudiante, error de
/// arranque (sesión guardada sin poder verificarse) o flujo de autenticación.
///
/// Todos los roles entran a la app del estudiante: `COMERCIO` y `REPARTIDOR` todavía no
/// tienen pantallas en ningún cliente.
struct RootRouterView: View {
    @Environment(AuthStore.self) private var authStore
    @Environment(CartStore.self) private var cartStore
    let container: AppContainer

    var body: some View {
        Group {
            if authStore.isLoading {
                bootSplash
            } else if authStore.isAuthenticated {
                StudentRootView(container: container)
            } else if let bootError = authStore.bootError {
                bootErrorView(bootError)
            } else {
                AuthFlowView()
            }
        }
        .task {
            await authStore.bootstrap()
        }
        // Logout, sesión expirada u otra cuenta: el carrito y el último salón pertenecen a quien los
        // usó, nunca a la siguiente persona en el dispositivo.
        .onChange(of: authStore.user?.id) {
            cartStore.reset()
        }
    }

    private var bootSplash: some View {
        ZStack {
            NMColors.paper.ignoresSafeArea()
            VStack(spacing: NMSpacing.s4) {
                Text("Nomi").nmStyle(.h1)
                ProgressView().tint(NMColors.accent)
            }
        }
    }

    /// La sesión guardada no se pudo verificar (sin conexión, servidor caído). Los tokens siguen
    /// guardados, así que basta con reintentar sin volver al login.
    private func bootErrorView(_ message: String) -> some View {
        ZStack {
            NMColors.paper.ignoresSafeArea()
            VStack(spacing: NMSpacing.s4) {
                Text("Nomi").nmStyle(.h1)
                Text(message)
                    .nmStyle(.body)
                    .multilineTextAlignment(.center)
                NMButton(label: "Reintentar", variant: .primary, fullWidth: true) {
                    Task { await authStore.bootstrap() }
                }
                NMButton(label: "Cerrar sesión", variant: .ghost, fullWidth: true) {
                    authStore.logout()
                }
            }
            .padding(NMSpacing.s6)
        }
    }
}
