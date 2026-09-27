import SwiftUI

/// Campo de texto con etiqueta flotante, icono opcional y mensaje de error o ayuda.
struct NMInput: View {
    let label: String
    @Binding var text: String
    /// Si hay error, se muestra en lugar de `helper` y el borde se pinta de rojo.
    var error: String?
    var helper: String?
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    /// Activa Autocompletar y las sugerencias de contraseña (`.username`, `.password`,
    /// `.newPassword`...).
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .sentences
    var autocorrectionDisabled: Bool = false
    var leftIcon: Image?
    var rightIcon: Image?
    var onRightIconTap: (() -> Void)?

    @FocusState private var isFocused: Bool

    private var isActive: Bool { isFocused || !text.isEmpty }

    var body: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s1) {
            HStack(spacing: NMSpacing.s2) {
                leftIcon?.foregroundColor(NMColors.neutral)

                ZStack(alignment: .leading) {
                    Text(label)
                        .nmStyle(.label, color: NMColors.neutral)
                        .offset(y: isActive ? -14 : 0)
                        .scaleEffect(isActive ? 0.85 : 1, anchor: .leading)

                    Group {
                        if isSecure {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .font(NMFont.medium(15))
                    .foregroundColor(NMColors.ink)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(autocorrectionDisabled)
                    .focused($isFocused)
                    // El campo siempre está montado y solo cambia su opacidad: si se desmontara, se perderían
                    // el foco y el texto al pasar de inactivo a activo.
                    .opacity(isActive ? 1 : 0)
                }
                .animation(NMEasing.inOut, value: isActive)

                if let rightIcon {
                    Button(action: { onRightIconTap?() }) {
                        rightIcon.foregroundColor(NMColors.neutral)
                    }
                }
            }
            .padding(.horizontal, NMSpacing.s4)
            .frame(minHeight: 60)
            .overlay(
                RoundedRectangle(cornerRadius: NMRadius.lg).stroke(borderColor, lineWidth: 1.5)
            )
            .contentShape(Rectangle())
            .onTapGesture { isFocused = true }

            if let error {
                Text(error).nmStyle(.label, color: NMColors.error)
            } else if let helper {
                Text(helper).nmStyle(.label, color: NMColors.neutral)
            }
        }
    }

    private var borderColor: Color {
        if error != nil { return NMColors.error }
        if isFocused { return NMColors.accent }
        return NMColors.line
    }
}
