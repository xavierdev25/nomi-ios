import Foundation

/// Renueva el par de tokens con `POST /auth/refresh`, garantizando una sola renovación en
/// vuelo aunque varias peticiones la pidan a la vez.
///
/// Es un actor porque es el único estado compartido de la capa de red. Entre comprobar
/// `inFlightRefresh` y guardar la tarea nueva no hay ningún `await`, así que la reentrada
/// del actor no puede duplicar la renovación.
actor TokenRefresher {
    private let tokenStore: TokenStoring
    private let baseURL: URL
    /// Sesión propia, distinta de la de `APIClient`: un `401` de `/auth/refresh` no debe volver
    /// a entrar en este mismo flujo de renovación.
    private let session: URLSession
    private var inFlightRefresh: Task<AuthTokens, Error>?

    init(
        tokenStore: TokenStoring,
        baseURL: URL = NetworkConfig.apiBaseURL,
        session: URLSession = URLSession(configuration: .ephemeral)
    ) {
        self.tokenStore = tokenStore
        self.baseURL = baseURL
        self.session = session
    }

    /// Devuelve tokens válidos, renovándolos si hace falta.
    ///
    /// El backend rota el refresh token en cada uso y trata el reuso como robo (revoca toda la
    /// sesión). Por eso, si el token almacenado ya no es `staleAccessToken`, otra petición ya lo
    /// renovó y se devuelve ese par en lugar de gastar el refresh token otra vez.
    /// - Parameter staleAccessToken: el access token que la petición vio expirar o rechazar.
    /// - Throws: `APIError.unauthorized` si el backend rechaza el refresh token.
    func refreshedTokens(replacing staleAccessToken: String) async throws -> AuthTokens {
        if let inFlight = inFlightRefresh {
            return try await inFlight.value
        }
        if let current = try tokenStore.currentTokens(), current.accessToken != staleAccessToken {
            return current
        }
        let task = Task { try await self.performRefresh() }
        inFlightRefresh = task
        defer { inFlightRefresh = nil }
        return try await task.value
    }

    private func performRefresh() async throws -> AuthTokens {
        guard let current = try tokenStore.currentTokens() else {
            throw APIError.unauthorized
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("auth/refresh"))
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder.nomi.encode(["refreshToken": current.refreshToken])

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        switch http.statusCode {
        case 200..<300:
            break
        // Refresh token inválido, expirado, revocado o reutilizado (`RefreshTokenHandler` responde
        // 400 en todos esos casos): la sesión terminó.
        case 400, 401, 403:
            throw APIError.unauthorized
        // Un error del servidor no dice nada sobre la sesión: se conserva.
        default:
            let payload = try? JSONDecoder.nomi.decode(ApiErrorPayload.self, from: data)
            throw APIError.server(
                payload ?? ApiErrorPayload(error: nil, message: nil, status: http.statusCode, timestamp: nil, fields: nil),
                statusCode: http.statusCode
            )
        }

        let auth: AuthResponse
        do {
            auth = try JSONDecoder.nomi.decode(AuthResponse.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }

        let tokens = AuthTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken)
        try tokenStore.save(tokens)
        return tokens
    }
}
