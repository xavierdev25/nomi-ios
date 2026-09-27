import Foundation

/// Cuerpo de error del backend. Todos los campos son opcionales a propósito: la forma varía
/// entre endpoints (el login inválido solo trae `error`) y un modelo con campos obligatorios
/// fallaría justo al decodificar el error que más importa mostrar.
struct ApiErrorPayload: Codable, Sendable {
    let error: String?
    let message: String?
    let status: Int?
    let timestamp: String?
    /// Mensaje por campo; solo en errores de validación (`@Valid`).
    let fields: [String: String]?

    /// Mensaje para el usuario. En un error de validación el texto útil está en `fields`
    /// (`message` ahí es el genérico "Hay errores en los campos enviados").
    func displayMessage(fallback: String) -> String {
        if let fields, !fields.isEmpty {
            return fields.keys.sorted().compactMap { fields[$0] }.joined(separator: "\n")
        }
        return message ?? error ?? fallback
    }
}
