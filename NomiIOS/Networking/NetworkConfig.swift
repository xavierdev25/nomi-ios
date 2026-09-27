import Foundation

/// Configuración de red. La URL es una constante de compilación: la URL de Release es un
/// marcador y todavía no hay configuración por entorno (ver la auditoría técnica, M10).
enum NetworkConfig {
    #if DEBUG
    static let apiBaseURL = URL(string: "http://localhost:8080/api")!
    #else
    static let apiBaseURL = URL(string: "https://api.nomi.app/api")!
    #endif

    /// Tiempo máximo por petición, en segundos.
    static let requestTimeout: TimeInterval = 15

    /// Margen, en segundos, con el que se renueva el access token antes de su `exp`. También
    /// absorbe pequeñas diferencias de reloj entre el dispositivo y el backend.
    static let tokenRefreshLeeway: TimeInterval = 60
}
