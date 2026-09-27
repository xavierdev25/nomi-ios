import SwiftUI

/// Chip seleccionable (categorías, propina, punto de encuentro). Sin `action` queda
/// deshabilitado.
struct NMTag: View {
    let label: String
    var selected: Bool = false
    var icon: Image?
    var action: (() -> Void)?

    var body: some View {
        Button(action: { action?() }) {
            HStack(spacing: NMSpacing.s1) {
                icon
                Text(label).nmStyle(.label, color: selected ? NMColors.onAccent : NMColors.inkSoft)
            }
            .padding(.horizontal, NMSpacing.s3)
            .frame(minHeight: 36)
            .background(selected ? NMColors.accent : NMColors.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(selected ? NMColors.accent : NMColors.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}
