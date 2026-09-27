import SwiftUI

/// Variantes de `NMCard`: con sombra suave, elevada, con borde o plana.
enum NMCardVariant {
    case standard, elevated, outlined, flat
}

/// Contenedor tipo tarjeta. Si recibe `action`, toda la tarjeta es pulsable.
struct NMCard<Content: View>: View {
    var variant: NMCardVariant = .standard
    var padding: CGFloat = NMSpacing.s4
    var action: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        if let action {
            Button(action: action) { cardBody }
                .buttonStyle(.plain)
        } else {
            cardBody
        }
    }

    private var cardBody: some View {
        content()
            .padding(padding)
            .background(NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay {
                if variant == .outlined {
                    RoundedRectangle(cornerRadius: NMRadius.lg)
                        .stroke(NMColors.line, lineWidth: 1)
                }
            }
            .nmShadow(shadowForVariant)
    }

    private var shadowForVariant: NMShadow {
        switch variant {
        case .standard: .whisper
        case .elevated: .raised
        case .outlined, .flat: .none
        }
    }
}
