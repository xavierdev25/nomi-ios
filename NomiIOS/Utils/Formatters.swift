import Foundation

/// Formateo de valores para la UI.
enum NMFormat {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// Soles con 2 decimales y punto decimal: `S/ 12.50`. La configuración regional fija evita
    /// que el formato cambie con el idioma del dispositivo.
    static func currency(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        return "S/ " + (numberFormatter.string(from: number) ?? "\(amount)")
    }

    /// `COMIDA` → `Comida`.
    static func category(_ raw: String) -> String {
        raw.prefix(1).uppercased() + raw.dropFirst().lowercased()
    }
}
