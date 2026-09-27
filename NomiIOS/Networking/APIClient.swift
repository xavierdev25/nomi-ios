import Foundation

/// Cliente HTTP de la API de Nomi: añade el token, renueva la sesión y traduce cada fallo
/// a un `APIError`.
///
/// Es una clase `Sendable` sin estado mutable; lo único que puede competir entre tareas (la
/// renovación del token) vive en el actor `TokenRefresher`.
final class APIClient: Sendable {
    private let baseURL: URL
    private let session: URLSession
    private let tokenStore: TokenStoring
    private let refresher: TokenRefresher
    private let onSessionExpired: SessionExpiring

    init(
        baseURL: URL = NetworkConfig.apiBaseURL,
        session: URLSession = .shared,
        tokenStore: TokenStoring,
        refresher: TokenRefresher,
        onSessionExpired: SessionExpiring
    ) {
        self.baseURL = baseURL
        self.session = session
        self.tokenStore = tokenStore
        self.refresher = refresher
        self.onSessionExpired = onSessionExpired
    }

    /// Ejecuta la petición y decodifica la respuesta con `JSONDecoder.nomi`.
    /// - Throws: `APIError` o `CancellationError` si la tarea que la lanzó se canceló.
    func send<Response: Decodable>(_ endpoint: APIEndpoint) async throws -> Response {
        let data = try await sendRaw(endpoint, hasRefreshed: false)
        do {
            return try JSONDecoder.nomi.decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    /// Para respuestas `204 No Content` (los `DELETE`): no intenta decodificar el cuerpo.
    func sendNoContent(_ endpoint: APIEndpoint) async throws {
        _ = try await sendRaw(endpoint, hasRefreshed: false)
    }

    /// Envía la petición con como máximo una renovación del token.
    /// - Parameter hasRefreshed: `true` si el token ya se renovó durante esta misma petición;
    ///   un segundo `401` con token recién emitido significa que la sesión ya no es válida.
    private func sendRaw(_ endpoint: APIEndpoint, hasRefreshed: Bool) async throws -> Data {
        var hasRefreshed = hasRefreshed
        var tokens = endpoint.requiresAuth ? try tokenStore.currentTokens() : nil

        // Renovación preventiva: el token se renueva antes de expirar en lugar de esperar al
        // rechazo. Así la sesión sobrevive aunque el backend responda a un token vencido con algo
        // distinto de 401 (antes de corregir `SecurityConfig` respondía 403).
        if let current = tokens, !hasRefreshed,
           JWT.isExpired(current.accessToken, leeway: NetworkConfig.tokenRefreshLeeway) {
            try await refreshTokens(replacing: current.accessToken)
            tokens = try tokenStore.currentTokens()
            hasRefreshed = true
        }

        let request = try buildRequest(for: endpoint, accessToken: tokens?.accessToken)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        // Una tarea cancelada (una `.task` que se desmonta, un pull-to-refresh interrumpido) no es
        // un problema de conexión: se propaga como cancelación para que la UI la ignore.
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Red de seguridad para lo que la renovación preventiva no cubre: token revocado o reloj
        // del dispositivo desfasado. Se renueva y se reintenta una sola vez.
        if http.statusCode == 401, endpoint.requiresAuth {
            guard !hasRefreshed, let sentToken = tokens?.accessToken else {
                await onSessionExpired.sessionDidExpire()
                throw APIError.unauthorized
            }
            try await refreshTokens(replacing: sentToken)
            return try await sendRaw(endpoint, hasRefreshed: true)
        }

        guard (200..<300).contains(http.statusCode) else {
            let payload = try? JSONDecoder.nomi.decode(ApiErrorPayload.self, from: data)
            throw APIError.server(
                payload ?? ApiErrorPayload(error: nil, message: nil, status: http.statusCode, timestamp: nil, fields: nil),
                statusCode: http.statusCode
            )
        }

        return data
    }

    /// Solo un refresh token rechazado cierra la sesión. Un fallo de red o un 5xx durante la
    /// renovación se propaga tal cual: cerrar sesión por una conexión inestable tiraría un
    /// refresh token que sigue siendo válido.
    private func refreshTokens(replacing staleAccessToken: String) async throws {
        do {
            _ = try await refresher.refreshedTokens(replacing: staleAccessToken)
        } catch APIError.unauthorized {
            await onSessionExpired.sessionDidExpire()
            throw APIError.unauthorized
        }
    }

    private func buildRequest(for endpoint: APIEndpoint, accessToken: String?) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidResponse
        }
        if !endpoint.query.isEmpty {
            components.queryItems = endpoint.query.compactMap { key, value in
                value.map { URLQueryItem(name: key, value: $0) }
            }
        }
        guard let url = components.url else { throw APIError.invalidResponse }

        var request = URLRequest(url: url, timeoutInterval: NetworkConfig.requestTimeout)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if endpoint.requiresAuth, let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        // Las cabeceras explícitas del endpoint tienen prioridad (ver `AuthAPI.logout`).
        for (name, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: name)
        }
        if let body = endpoint.body {
            request.httpBody = body
        }
        return request
    }
}
