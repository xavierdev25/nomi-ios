import SwiftUI

/// Duraciones de animación: micro (feedback de pulsación), short (cambios de estado) y long
/// (hojas, modales, transiciones de página).
enum NMDuration {
    static let micro: TimeInterval = 0.12
    static let short: TimeInterval = 0.22
    static let long: TimeInterval = 0.42
}

/// Curvas de animación. Sin rebote: `out` para lo que entra, `in` para lo que sale e `inOut`
/// para cambios de estado.
enum NMEasing {
    static let out = Animation.timingCurve(0.16, 1, 0.3, 1, duration: NMDuration.short)
    static let `in` = Animation.timingCurve(0.7, 0, 0.84, 0, duration: NMDuration.short * 0.75)
    static let inOut = Animation.timingCurve(0.65, 0, 0.35, 1, duration: NMDuration.short)

    static let outLong = Animation.timingCurve(0.16, 1, 0.3, 1, duration: NMDuration.long)
    static let inLong = Animation.timingCurve(0.7, 0, 0.84, 0, duration: NMDuration.long * 0.75)

    static let outMicro = Animation.timingCurve(0.16, 1, 0.3, 1, duration: NMDuration.micro)
}
