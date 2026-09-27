import SwiftUI

/// Inicio de sesión con email y contraseña.
struct LoginView: View {
    @Environment(AuthStore.self) private var authStore

    @State private var email = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showRegister = false

    private var canSubmit: Bool {
        !email.isEmpty && !password.isEmpty && !isSubmitting
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                VStack(alignment: .leading, spacing: NMSpacing.s1) {
                    Text("Bienvenido de nuevo").nmStyle(.h1)
                    Text("Inicia sesión para continuar").nmStyle(.body)
                }
                .padding(.top, NMSpacing.s6)

                NMInput(label: "Correo electrónico", text: $email, keyboardType: .emailAddress,
                        textContentType: .username, autocapitalization: .never, autocorrectionDisabled: true,
                        leftIcon: Image(nmIcon: NMIcon.mail))
                NMInput(label: "Contraseña", text: $password, isSecure: true, textContentType: .password,
                        leftIcon: Image(nmIcon: NMIcon.lock))

                if let errorMessage {
                    errorBanner(errorMessage)
                }

                NMButton(label: "Iniciar sesión", variant: .primary, loading: isSubmitting, disabled: !canSubmit, fullWidth: true) {
                    Task { await submit() }
                }

                HStack(spacing: 4) {
                    Text("¿No tienes cuenta?").nmStyle(.body)
                    Button("Regístrate") { showRegister = true }
                        .font(NMFont.semibold(14))
                        .foregroundColor(NMColors.accent)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(NMSpacing.s6)
        }
        .background(NMColors.paper)
        .navigationTitle("Iniciar sesión")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showRegister) { RegisterView() }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: NMSpacing.s1) {
            Image(nmIcon: NMIcon.alertCircle).foregroundColor(NMColors.error)
            Text(message).nmStyle(.body, color: NMColors.error)
        }
        .padding(NMSpacing.s3)
        .background(NMColors.errorSoft)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.md))
    }

    private func submit() async {
        errorMessage = nil
        isSubmitting = true
        defer { isSubmitting = false }
        do {
            try await authStore.login(email: email.trimmingCharacters(in: .whitespaces), password: password)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }
}
