import Foundation

/// Lee la expiración (`exp`) de un access token sin verificar la firma: el backend sigue
/// siendo la autoridad sobre su validez; el cliente solo necesita saber cuándo renovarlo.
enum JWT {
    /// - Returns: la fecha de `exp`, o `nil` si el token no es un JWT legible.
    static func expirationDate(of token: String) -> Date? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }
        var base64 = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        base64 += String(repeating: "=", count: (4 - base64.count % 4) % 4)
        guard let data = Data(base64Encoded: base64),
              let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: exp)
    }

    /// `true` si el token ya expiró o expira dentro de `leeway` segundos. Un token sin `exp`
    /// legible cuenta como vigente y queda cubierto por el reintento ante `401`.
    static func isExpired(_ token: String, leeway: TimeInterval, now: Date = .now) -> Bool {
        guard let expiration = expirationDate(of: token) else { return false }
        return expiration.timeIntervalSince(now) <= leeway
    }
}
