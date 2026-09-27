import SwiftUI

/// Perfil: datos del usuario, accesos a favoritos y recomendaciones, y cierre de sesión.
struct ProfileView: View {
    @Environment(AuthStore.self) private var authStore
    @Binding var path: NavigationPath
    @State private var showLogoutConfirm = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s6) {
                header
                menu
                NMButton(label: "Cerrar sesión", variant: .outline, fullWidth: true) {
                    showLogoutConfirm = true
                }
                .padding(.horizontal, NMSpacing.s5)
            }
            .padding(.top, NMSpacing.s6)
        }
        .background(NMColors.paper)
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("¿Cerrar sesión?", isPresented: $showLogoutConfirm, titleVisibility: .visible) {
            Button("Cerrar sesión", role: .destructive) {
                authStore.logout()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack(spacing: NMSpacing.s3) {
            NMAvatar(name: fullName, size: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text(fullName.isEmpty ? "Estudiante" : fullName).nmStyle(.h3)
                if let email = authStore.user?.email {
                    Text(email).nmStyle(.body)
                }
            }
        }
        .padding(.horizontal, NMSpacing.s5)
    }

    private var menu: some View {
        VStack(spacing: NMSpacing.s2) {
            menuRow(icon: NMIcon.heart, title: "Productos favoritos") {
                path.append(StudentRoute.favoriteProducts)
            }
            menuRow(icon: NMIcon.storefront, title: "Tiendas favoritas") {
                path.append(StudentRoute.favoriteStores)
            }
            menuRow(icon: NMIcon.sparkles, title: "Recomendaciones para ti") {
                path.append(StudentRoute.recommendations)
            }
            // Sin acción: todavía no existe la pantalla para editar restricciones y preferencias.
            menuRow(icon: NMIcon.shield, title: "Restricciones y preferencias", showChevron: false) {}
        }
        .padding(.horizontal, NMSpacing.s5)
    }

    private func menuRow(icon: String, title: String, showChevron: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: NMSpacing.s3) {
                Image(nmIcon: icon).foregroundColor(NMColors.accent).frame(width: 22)
                Text(title).nmStyle(.bodyStrong)
                Spacer()
                if showChevron {
                    Image(nmIcon: NMIcon.chevronForward).foregroundColor(NMColors.neutral)
                }
            }
            .padding(NMSpacing.s3)
            .background(NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var fullName: String {
        guard let user = authStore.user else { return "" }
        return [user.nombres, user.apellidos].compactMap { $0 }.joined(separator: " ")
    }
}
