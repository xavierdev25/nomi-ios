import Foundation

/// Configuración de red.
enum NetworkConfig {
    /// URL base de la API. Sale de la variable de compilación `NOMI_API_BASE_URL`
    /// (`Config/Debug.xcconfig`, `Config/Release.xcconfig` y el opcional `Config/Local.xcconfig`),
    /// que el Info.plist expone como `NomiAPIBaseURL`. Así se puede apuntar la app a otro backend
    /// (por ejemplo, el Mac desde un iPhone físico) sin tocar el código.
    static let apiBaseURL: URL = apiBaseURL(from: Bundle.main.infoDictionary)

    /// Clave del Info.plist con la URL base.
    static let apiBaseURLInfoKey = "NomiAPIBaseURL"

    /// URL que se usa si el Info.plist no trae una válida: la misma que había antes de hacerla
    /// configurable. La de Release todavía es un marcador (ver la auditoría técnica, M10).
    #if DEBUG
    static let defaultAPIBaseURL = URL(string: "http://localhost:8080/api")!
    #else
    static let defaultAPIBaseURL = URL(string: "https://api.nomi.app/api")!
    #endif

    /// Lee la URL del Info.plist. Una clave ausente, vacía, sin sustituir (`$(NOMI_API_BASE_URL)`)
    /// o que no sea una URL http/https con host cae en `defaultAPIBaseURL`: una configuración rota
    /// nunca deja la app sin backend.
    static func apiBaseURL(from info: [String: Any]?) -> URL {
        guard let raw = (info?[apiBaseURLInfoKey] as? String)?.trimmingCharacters(in: .whitespaces),
              let url = URL(string: raw),
              let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https",
              let host = url.host, !host.isEmpty else {
            return defaultAPIBaseURL
        }
        return url
    }

    /// Tiempo máximo por petición, en segundos.
    static let requestTimeout: TimeInterval = 15

    /// Margen, en segundos, con el que se renueva el access token antes de su `exp`. También
    /// absorbe pequeñas diferencias de reloj entre el dispositivo y el backend.
    static let tokenRefreshLeeway: TimeInterval = 60
}
