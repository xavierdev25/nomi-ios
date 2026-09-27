import SwiftUI

/// Tipografía: San Francisco (fuente del sistema) en todos los casos. La jerarquía se
/// construye con peso y tamaño, sin fuentes empaquetadas.
enum NMFont {
    static func regular(_ size: CGFloat) -> Font { .system(size: size, weight: .regular) }
    static func medium(_ size: CGFloat) -> Font { .system(size: size, weight: .medium) }
    static func semibold(_ size: CGFloat) -> Font { .system(size: size, weight: .semibold) }
    static func bold(_ size: CGFloat) -> Font { .system(size: size, weight: .bold) }
    static func heavy(_ size: CGFloat) -> Font { .system(size: size, weight: .heavy) }

    /// Dígitos de ancho fijo para precios y cifras alineadas.
    static func numeric(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight).monospacedDigit()
    }
}
