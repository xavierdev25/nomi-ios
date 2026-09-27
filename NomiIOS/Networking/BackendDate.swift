import Foundation

/// Decodifica las fechas del backend, que serializa `LocalDateTime` de Java: sin zona
/// horaria y con 0 a 9 dígitos fraccionarios (`2026-07-25T14:30:00` o
/// `2026-07-25T14:30:00.123456789`). La estrategia `.iso8601` de Foundation exige zona y
/// falla con todas ellas.
///
/// Las fechas se interpretan como UTC, pero hoy el backend las emite en hora local del
/// servidor (ver la auditoría técnica, M7): hay que tenerlo en cuenta antes de mostrarlas.
enum BackendDate {
    private static func makeFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = format
        return formatter
    }

    private static let withFraction = makeFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS")
    private static let withoutFraction = makeFormatter("yyyy-MM-dd'T'HH:mm:ss")

    /// Normaliza la parte fraccionaria a exactamente 3 dígitos y parsea con formato fijo.
    /// - Returns: `nil` si el texto no tiene el formato esperado.
    static func parse(_ raw: String) -> Date? {
        guard let dotIndex = raw.firstIndex(of: ".") else {
            return withoutFraction.date(from: raw)
        }
        let wholePart = raw[..<dotIndex]
        var fraction = raw[raw.index(after: dotIndex)...]
        if fraction.count > 3 {
            fraction = fraction.prefix(3)
        } else if fraction.count < 3 {
            fraction += String(repeating: "0", count: 3 - fraction.count)
        }
        return withFraction.date(from: "\(wholePart).\(fraction)")
    }

    static let decodingStrategy: JSONDecoder.DateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let date = parse(raw) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "No se pudo interpretar la fecha del backend: \(raw)"
            )
        }
        return date
    }
}

/// Decodificador que debe usar toda respuesta del backend (instala `BackendDate`).
extension JSONDecoder {
    static var nomi: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = BackendDate.decodingStrategy
        return decoder
    }
}

/// Codificador de los cuerpos que se envían al backend.
extension JSONEncoder {
    static var nomi: JSONEncoder {
        JSONEncoder()
    }
}
