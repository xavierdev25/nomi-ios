import SwiftUI

/// Sombras. La profundidad viene primero de la luminosidad; la sombra es la excepción y
/// nunca se apila.
struct NMShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    let opacity: Double

    static let none = NMShadow(color: .clear, radius: 0, x: 0, y: 0, opacity: 0)
    /// Tarjetas en reposo: separación apenas perceptible.
    static let whisper = NMShadow(color: NMColors.ink, radius: 3, x: 0, y: 1, opacity: 0.05)
    /// Elementos realmente elevados: hojas, barras fijas, controles flotantes.
    static let raised = NMShadow(color: NMColors.ink, radius: 10, x: 0, y: 3, opacity: 0.08)
    /// Resplandor del botón primario; el único uso de color en una sombra.
    static let accentGlow = NMShadow(color: NMColors.accent, radius: 14, x: 0, y: 8, opacity: 0.22)
}

/// Aplicación de `NMShadow` a cualquier vista.
extension View {
    func nmShadow(_ shadow: NMShadow) -> some View {
        self.shadow(color: shadow.color.opacity(shadow.opacity), radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
