import SwiftUI

/// Pantalla de bienvenida con acceso a iniciar sesión o crear cuenta.
struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showRegister = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: NMSpacing.s16)

            accentMark
                .padding(.leading, NMSpacing.s6)

            Spacer(minLength: NMSpacing.s6)

            brandBlock
                .padding(.horizontal, NMSpacing.s6)

            Spacer(minLength: NMSpacing.s8)

            actions
                .padding(.horizontal, NMSpacing.s6)
                .padding(.bottom, NMSpacing.s8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(NMColors.paper.ignoresSafeArea())
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showLogin) { LoginView() }
        .navigationDestination(isPresented: $showRegister) { RegisterView() }
    }

    private var accentMark: some View {
        RoundedRectangle(cornerRadius: NMRadius.sm)
            .fill(NMColors.accent)
            .frame(width: 28, height: 28)
            .rotationEffect(.degrees(-8))
    }

    private var brandBlock: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            Text("Nomi")
                .nmStyle(.display, color: NMColors.ink)
            Text("Pide en tu salón. Llega entre clases.")
                .font(NMFont.medium(19))
                .foregroundColor(NMColors.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actions: some View {
        VStack(spacing: NMSpacing.s3) {
            NMButton(label: "Iniciar sesión", variant: .primary, fullWidth: true) {
                showLogin = true
            }
            NMButton(label: "Crear cuenta", variant: .secondary, fullWidth: true) {
                showRegister = true
            }
        }
    }
}
