import Foundation

/// Verbos HTTP que usa la API.
enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Descripción de una petición: ruta relativa a `NetworkConfig.apiBaseURL`, método, query,
/// cuerpo y si requiere sesión.
///
/// El cuerpo va ya codificado (`Data`) en lugar de `any Encodable`: la codificación genérica
/// ocurre en `encoding(_:path:method:query:requiresAuth:)` con el tipo concreto.
struct APIEndpoint: Sendable {
    var path: String
    var method: HTTPMethod = .get
    /// Los valores `nil` se omiten al construir la URL.
    var query: [String: String?] = [:]
    var body: Data?
    /// Si es `true`, `APIClient` añade el access token y gestiona su renovación.
    var requiresAuth: Bool = true
    /// Cabeceras extra, aplicadas después de las por defecto. Sirven para llamadas que deben
    /// llevar un token concreto en vez del almacenado (ver `AuthAPI.logout`).
    var headers: [String: String] = [:]

    /// Construye un endpoint con cuerpo JSON codificado con `JSONEncoder.nomi`.
    static func encoding(
        _ body: some Encodable,
        path: String,
        method: HTTPMethod,
        query: [String: String?] = [:],
        requiresAuth: Bool = true
    ) throws -> APIEndpoint {
        APIEndpoint(
            path: path,
            method: method,
            query: query,
            body: try JSONEncoder.nomi.encode(body),
            requiresAuth: requiresAuth
        )
    }
}
