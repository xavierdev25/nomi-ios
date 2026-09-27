import Foundation

/// Usuario autenticado. Casi todo es opcional porque `/users/me` devuelve los datos del
/// token y no el registro completo: apellidos o `creadoEn` llegan nulos aunque existan.
struct User: Codable, Identifiable, Sendable {
    let id: Int
    let nombres: String?
    let apellidos: String?
    let email: String
    let telefono: String?
    let role: UserRole
    let esRepartidor: Bool?
    let campusId: Int?
    let activo: Bool
    let creadoEn: Date?
    let preferences: [String]?
    let restrictions: [String]?
    let budgetRange: String?
    let cuisineTypes: [String]?
}

/// Roles del sistema. La app solo tiene pantallas para `ESTUDIANTE`.
enum UserRole: String, Codable, Sendable {
    case estudiante = "ESTUDIANTE"
    case repartidor = "REPARTIDOR"
    case comercio = "COMERCIO"
    case admin = "ADMIN"
}

/// Respuesta de login y refresh.
struct AuthResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    /// Duración del access token, en milisegundos.
    let expiresIn: Int
}

/// Cuerpo de `POST /auth/login`.
struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

/// Cuerpo de `POST /auth/register`. Las reglas de cada campo están en
/// `RegistrationValidator`, que replica las del backend.
struct RegisterRequest: Codable, Sendable {
    let nombres: String
    let apellidos: String
    let email: String
    let password: String
    let telefono: String?
    let role: UserRole
    let preferences: [String]?
    let restrictions: [String]?
    let budgetRange: String?
    let cuisineTypes: [String]?
}

/// Respuesta `{"message": "..."}` de registro y logout.
struct MessageResponse: Codable, Sendable {
    let message: String
}
