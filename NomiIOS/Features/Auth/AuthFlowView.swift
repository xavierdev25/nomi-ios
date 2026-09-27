import SwiftUI

/// Pila de autenticación: bienvenida → inicio de sesión o registro.
struct AuthFlowView: View {
    var body: some View {
        NavigationStack {
            WelcomeView()
        }
    }
}
