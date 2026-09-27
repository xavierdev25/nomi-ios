import Foundation

/// Errores de red y de API, con mensajes en español listos para mostrar al usuario.
enum APIError: Error, LocalizedError, Sendable {
    /// La sesión ya no es válida y se cerró.
    case unauthorized
    /// El backend respondió con un estado de error; el cuerpo se decodifica si es posible.
    case server(ApiErrorPayload, statusCode: Int)
    /// La respuesta no coincide con el modelo esperado.
    case decoding(Error)
    /// No hubo respuesta: sin conexión, timeout o servidor inaccesible.
    case transport(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            "Sesión expirada. Inicia sesión de nuevo."
        case .server(let payload, _):
            payload.displayMessage(fallback: "Ocurrió un error inesperado. Intenta de nuevo.")
        case .decoding:
            "No se pudo interpretar la respuesta del servidor."
        case .transport:
            "No se pudo conectar. Revisa tu conexión."
        case .invalidResponse:
            "Respuesta inválida del servidor."
        }
    }
}
