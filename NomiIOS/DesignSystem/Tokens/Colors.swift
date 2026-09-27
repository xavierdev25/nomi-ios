import SwiftUI

/// Paleta de Nomi. Dos tonos con papel fijo: naranja cálido como único color de acción
/// (botones, estados activos, precios) y azul marino solo para texto, nunca como fondo.
/// Los neutros están teñidos hacia el tono cálido en lugar de ser grises puros.
enum NMColors {

    /// Fondo de página.
    static let paper = Color.oklch(0.970, 0.010, 55)
    /// Tarjetas y superficies elevadas: más claras que `paper`, la profundidad se da por luminosidad.
    static let surface = Color.oklch(0.992, 0.004, 55)
    /// Bandas y marcadores de posición de imagen.
    static let paperRaised = Color.oklch(0.940, 0.014, 55)
    /// Bordes finos y divisores.
    static let line = Color.oklch(0.880, 0.012, 55)

    /// Texto principal.
    static let ink = Color.oklch(0.180, 0.045, 258)
    static let inkSoft = Color.oklch(0.400, 0.032, 255)
    static let inkFaint = Color.oklch(0.620, 0.020, 250)
    /// Iconos y elementos secundarios; no para texto ni bordes.
    static let neutral = Color.oklch(0.680, 0.018, 52)

    /// Color de acción: botones primarios, estados activos y precios.
    static let accent = Color.oklch(0.700, 0.190, 48)
    static let accentStrong = Color.oklch(0.600, 0.185, 46)
    static let accentSoft = Color.oklch(0.930, 0.045, 55)
    /// Texto e iconos sobre un fondo `accent`.
    static let onAccent = Color.oklch(0.990, 0.006, 55)

    /// Colores semánticos; las variantes `Soft` son sus fondos.
    static let success = Color.oklch(0.600, 0.140, 152)
    static let successSoft = Color.oklch(0.940, 0.035, 152)
    static let warning = Color.oklch(0.720, 0.140, 75)
    static let warningSoft = Color.oklch(0.940, 0.045, 80)
    static let error = Color.oklch(0.560, 0.190, 25)
    static let errorSoft = Color.oklch(0.940, 0.045, 25)

    /// Azul informativo, solo para indicadores de estado del pedido; nunca como fondo.
    static let info = Color.oklch(0.550, 0.130, 258)
    static let infoStrong = Color.oklch(0.400, 0.095, 258)
    static let infoSoft = Color.oklch(0.940, 0.030, 258)
}
