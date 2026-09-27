import Foundation

/// Autenticación y usuario actual.
struct AuthAPI: Sendable {
    let client: APIClient

    /// Credenciales inválidas responden `401` con `{"error": "Invalid credentials"}`. El email se
    /// normaliza en el servidor (trim + minúsculas).
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = try APIEndpoint.encoding(
            LoginRequest(email: email, password: password),
            path: "auth/login",
            method: .post,
            requiresAuth: false
        )
        return try await client.send(endpoint)
    }

    /// Devuelve solo un mensaje de confirmación, no el usuario: para obtenerlo hay que iniciar
    /// sesión y llamar a `me()`.
    func register(_ request: RegisterRequest) async throws -> MessageResponse {
        let endpoint = try APIEndpoint.encoding(
            request,
            path: "auth/register",
            method: .post,
            requiresAuth: false
        )
        return try await client.send(endpoint)
    }

    /// `GET /users/me`. El backend responde con los datos del token (id, email, rol, nombres);
    /// apellidos, teléfono y preferencias llegan nulos (ver la auditoría técnica, M6).
    func me() async throws -> User {
        try await client.send(APIEndpoint(path: "users/me", method: .get))
    }

    /// Revoca la sesión en el servidor: todos los refresh tokens del usuario y el access token
    /// actual. Recibe los tokens explícitamente porque quien llama ya los borró del almacén;
    /// `requiresAuth: false` evita que `APIClient` lea el almacén vacío o intente renovar.
    func logout(_ tokens: AuthTokens) async throws {
        var endpoint = try APIEndpoint.encoding(
            LogoutRequest(refreshToken: tokens.refreshToken),
            path: "auth/logout",
            method: .post,
            requiresAuth: false
        )
        endpoint.headers["Authorization"] = "Bearer \(tokens.accessToken)"
        let _: MessageResponse = try await client.send(endpoint)
    }
}

private struct LogoutRequest: Encodable {
    let refreshToken: String
}
