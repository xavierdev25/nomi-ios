import SwiftUI

/// Variantes visuales de `NMButton`. `primary` es la acción principal de la pantalla.
enum NMButtonVariant {
    case primary, secondary, ghost, outline, danger
}

/// Alturas mínimas: 40, 50 y 56 pt.
enum NMButtonSize {
    case sm, md, lg
}

/// Botón del sistema de diseño. Con `loading` muestra un indicador y deja de responder; con
/// `disabled` además se atenúa.
struct NMButton: View {
    let label: String
    var variant: NMButtonVariant = .primary
    var size: NMButtonSize = .md
    var loading: Bool = false
    var disabled: Bool = false
    var fullWidth: Bool = false
    var leftIcon: Image?
    var rightIcon: Image?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: NMSpacing.s2) {
                if loading {
                    ProgressView().tint(labelColor)
                } else {
                    leftIcon
                    Text(label).nmStyle(.button, color: labelColor)
                    rightIcon
                }
            }
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, horizontalPadding)
            .frame(minHeight: minHeight)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: NMRadius.lg).stroke(borderColor, lineWidth: 1)
            )
            .nmShadow(variant == .primary ? .accentGlow : .none)
        }
        .buttonStyle(.plain)
        .disabled(disabled || loading)
        .opacity(disabled ? 0.5 : 1)
    }

    private var minHeight: CGFloat {
        switch size {
        case .sm: 40
        case .md: 50
        case .lg: 56
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .sm: NMSpacing.s4
        case .md: NMSpacing.s5
        case .lg: NMSpacing.s6
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary: NMColors.accent
        case .secondary, .outline: NMColors.surface
        case .ghost: .clear
        case .danger: NMColors.error
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary: NMColors.accent
        case .danger: NMColors.error
        case .secondary, .outline: NMColors.accent
        case .ghost: .clear
        }
    }

    private var labelColor: Color {
        switch variant {
        case .primary, .danger: NMColors.onAccent
        case .secondary, .outline, .ghost: NMColors.accent
        }
    }
}
