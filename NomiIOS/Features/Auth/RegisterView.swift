import SwiftUI

/// Registro de estudiantes. Solo ofrece el rol `ESTUDIANTE`: los demás roles no tienen
/// pantallas y quedarían sin nada que hacer tras registrarse.
struct RegisterView: View {
    @Environment(AuthStore.self) private var authStore

    @State private var nombres = ""
    @State private var apellidos = ""
    @State private var email = ""
    @State private var telefono = ""
    @State private var password = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    /// Los errores por campo aparecen tras el primer intento de envío y luego se actualizan en
    /// vivo mientras el usuario corrige.
    @State private var showFieldErrors = false

    private var canSubmit: Bool {
        !nombres.isEmpty && !apellidos.isEmpty && !email.isEmpty && !password.isEmpty && !isSubmitting
    }

    private var fieldErrors: RegistrationValidator.Errors {
        RegistrationValidator.validate(nombres: nombres, apellidos: apellidos, email: email, telefono: telefono, password: password)
    }

    private func visibleError(_ keyPath: KeyPath<RegistrationValidator.Errors, String?>) -> String? {
        showFieldErrors ? fieldErrors[keyPath: keyPath] : nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                VStack(alignment: .leading, spacing: NMSpacing.s1) {
                    Text("Crea tu cuenta").nmStyle(.h1)
                    Text("Regístrate como estudiante").nmStyle(.body)
                }
                .padding(.top, NMSpacing.s6)

                NMInput(label: "Nombres", text: $nombres, error: visibleError(\.nombres),
                        textContentType: .givenName, autocapitalization: .words)
                NMInput(label: "Apellidos", text: $apellidos, error: visibleError(\.apellidos),
                        textContentType: .familyName, autocapitalization: .words)
                NMInput(label: "Correo electrónico", text: $email, error: visibleError(\.email),
                        keyboardType: .emailAddress, textContentType: .emailAddress,
                        autocapitalization: .never, autocorrectionDisabled: true,
                        leftIcon: Image(nmIcon: NMIcon.mail))
                NMInput(label: "Teléfono (opcional)", text: $telefono, error: visibleError(\.telefono),
                        keyboardType: .phonePad, textContentType: .telephoneNumber,
                        leftIcon: Image(nmIcon: NMIcon.phone))
                NMInput(label: "Contraseña", text: $password, error: visibleError(\.password),
                        helper: RegistrationValidator.passwordHint, isSecure: true,
                        textContentType: .newPassword, leftIcon: Image(nmIcon: NMIcon.lock))

                if let errorMessage {
                    errorBanner(errorMessage)
                }

                NMButton(label: "Crear cuenta", variant: .primary, loading: isSubmitting, disabled: !canSubmit, fullWidth: true) {
                    Task { await submit() }
                }
            }
            .padding(NMSpacing.s6)
        }
        .background(NMColors.paper)
        .navigationTitle("Crear cuenta")
        .navigationBarTitleDisplayMode(.inline)
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
        guard fieldErrors.isEmpty else {
            showFieldErrors = true
            return
        }
        isSubmitting = true
        defer { isSubmitting = false }
        let trimmedPhone = telefono.trimmingCharacters(in: .whitespaces)
        let request = RegisterRequest(
            nombres: nombres.trimmingCharacters(in: .whitespaces),
            apellidos: apellidos.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            password: password,
            telefono: trimmedPhone.isEmpty ? nil : trimmedPhone,
            role: .estudiante,
            preferences: nil,
            restrictions: nil,
            budgetRange: nil,
            cuisineTypes: nil
        )
        do {
            try await authStore.register(request)
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Ocurrió un error inesperado. Intenta de nuevo."
        }
    }
}
