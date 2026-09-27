import SwiftUI

/// Variantes de color de `NMBadge`.
enum NMBadgeVariant {
    case orange, blue, success, warning, error, gray
}

/// Etiqueta compacta en forma de cápsula (categoría, "Agotado", "Última usada").
struct NMBadge: View {
    let label: String
    var variant: NMBadgeVariant = .orange

    var body: some View {
        Text(label)
            .nmStyle(.label, color: colors.fg)
            .padding(.horizontal, NMSpacing.s2)
            .padding(.vertical, NMSpacing.s1)
            .background(colors.bg)
            .clipShape(Capsule())
    }

    private var colors: (bg: Color, fg: Color) {
        switch variant {
        case .orange: (NMColors.accent, NMColors.onAccent)
        case .blue: (NMColors.info, NMColors.onAccent)
        case .success: (NMColors.successSoft, NMColors.success)
        case .warning: (NMColors.warningSoft, NMColors.warning)
        case .error: (NMColors.errorSoft, NMColors.error)
        case .gray: (NMColors.paperRaised, NMColors.inkSoft)
        }
    }
}
