import SwiftUI

/// Estilos de texto con nombre. Aplicarlos con `Text.nmStyle(_:color:)`.
struct NMTextStyle {
    let font: Font
    let lineHeight: CGFloat
    let color: Color

    static let display = NMTextStyle(font: NMFont.heavy(40), lineHeight: 46, color: NMColors.ink)
    static let h1 = NMTextStyle(font: NMFont.bold(32), lineHeight: 38, color: NMColors.ink)
    static let h2 = NMTextStyle(font: NMFont.bold(24), lineHeight: 30, color: NMColors.ink)
    static let h3 = NMTextStyle(font: NMFont.semibold(18), lineHeight: 24, color: NMColors.ink)
    static let body = NMTextStyle(font: NMFont.regular(14), lineHeight: 20, color: NMColors.inkSoft)
    static let bodyStrong = NMTextStyle(font: NMFont.semibold(14), lineHeight: 20, color: NMColors.ink)
    static let label = NMTextStyle(font: NMFont.semibold(12), lineHeight: 16, color: NMColors.inkSoft)
    static let button = NMTextStyle(font: NMFont.semibold(15), lineHeight: 20, color: NMColors.onAccent)
    static let price = NMTextStyle(font: NMFont.numeric(16), lineHeight: 22, color: NMColors.accent)
}

/// Aplicación de `NMTextStyle` a un `Text`.
extension Text {
    /// - Parameter overrideColor: sustituye el color del estilo (p. ej. para errores).
    func nmStyle(_ style: NMTextStyle, color overrideColor: Color? = nil) -> Text {
        self.font(style.font).foregroundColor(overrideColor ?? style.color)
    }
}
