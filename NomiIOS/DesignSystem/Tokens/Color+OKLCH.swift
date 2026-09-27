import SwiftUI

/// Colores definidos en OKLCH, el espacio en el que se diseña toda la paleta: la
/// luminosidad es perceptualmente uniforme, a diferencia de HSL.
extension Color {
    /// Convierte OKLCH a sRGB (conversión OKLab de Björn Ottosson). Los valores fuera de gama se
    /// recortan a [0, 1] por canal.
    /// - Parameters:
    ///   - l: luminosidad, de 0 a 1.
    ///   - c: croma, aproximadamente de 0 a 0,4 (por encima de ~0,25 suele salir de sRGB).
    ///   - h: tono, en grados.
    static func oklch(_ l: Double, _ c: Double, _ h: Double, opacity: Double = 1) -> Color {
        let hRad = h * .pi / 180
        let a = c * cos(hRad)
        let b = c * sin(hRad)

        let l_ = l + 0.3963377774 * a + 0.2158037573 * b
        let m_ = l - 0.1055613458 * a - 0.0638541728 * b
        let s_ = l - 0.0894841775 * a - 1.2914855480 * b

        let lc = l_ * l_ * l_
        let mc = m_ * m_ * m_
        let sc = s_ * s_ * s_

        let rLinear = 4.0767416621 * lc - 3.3077115913 * mc + 0.2309699292 * sc
        let gLinear = -1.2684380046 * lc + 2.6097574011 * mc - 0.3413193965 * sc
        let bLinear = -0.0041960863 * lc - 0.7034186147 * mc + 1.7076147010 * sc

        return Color(
            .sRGB,
            red: gammaEncode(rLinear),
            green: gammaEncode(gLinear),
            blue: gammaEncode(bLinear),
            opacity: opacity
        )
    }

    private static func gammaEncode(_ channel: Double) -> Double {
        let c = min(max(channel, 0), 1)
        return c <= 0.0031308 ? c * 12.92 : 1.055 * pow(c, 1 / 2.4) - 0.055
    }
}
