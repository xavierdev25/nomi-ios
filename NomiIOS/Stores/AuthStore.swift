import Observation

/// Estado de la sesión: fuente de verdad sobre quién está autenticado.
///
/// `authAPI` se asigna después de la inicialización para romper el ciclo con `APIClient`
/// (ver `AppContainer`).
@MainActor
@Observable
final class AuthStore: SessionExpiring, @unchecked Sendable {
    private(set) var user: User?
    /// `true` mientras se verifica la sesión guardada al arrancar.
    private(set) var isLoading = true
    /// Mensaje cuando la sesión guardada no se pudo verificar por un motivo distinto a que el
    /// servidor la rechace (sin conexión, servidor caído). Los tokens se conservan y basta con
    /// reintentar.
    private(set) var bootError: String?
    var authAPI: AuthAPI!

    private let tokenStore: TokenStoring

    var isAuthenticated: Bool { user != nil }

    init(tokenStore: TokenStoring) {
        self.tokenStore = tokenStore
    }

    /// Verifica la sesión guardada llamando a `/users/me`. Solo borra los tokens si el servidor
    /// la rechaza; sin conexión conserva la sesión y expone `bootError`.
    func bootstrap() async {
        isLoading = true
        bootError = nil
        defer { isLoading = false }

        guard (try? tokenStore.currentTokens()) != nil else {
            user = nil
            return
        }
        do {
            user = try await authAPI.me()
        } catch APIError.unauthorized {
            clearLocalSession()
        } catch {
            bootError = (error as? APIError)?.errorDescription ?? "No se pudo verificar tu sesión."
        }
    }

    /// Inicia sesión, guarda los tokens en el Keychain y carga el usuario.
    func login(email: String, password: String) async throws {
        let auth = try await authAPI.login(email: email, password: password)
        try tokenStore.save(AuthTokens(accessToken: auth.accessToken, refreshToken: auth.refreshToken))
        user = try await authAPI.me()
    }

    /// Registra al estudiante e inicia sesión con las mismas credenciales, porque el registro
    /// no devuelve tokens.
    func register(_ request: RegisterRequest) async throws {
        _ = try await authAPI.register(request)
        try await login(email: request.email, password: request.password)
    }

    /// Cierra la sesión: primero en local, para que la UI no espere a la red, y después la
    /// revoca en el servidor. La revocación es best effort: si falla, el refresh token expira
    /// solo.
    func logout() {
        let tokens = try? tokenStore.currentTokens()
        clearLocalSession()
        guard let tokens, let authAPI else { return }
        Task { try? await authAPI.logout(tokens) }
    }

    /// `nonisolated` porque `SessionExpiring` no está atado al hilo principal y lo llama
    /// `APIClient` desde cualquier contexto; salta al `MainActor` para tocar el estado.
    nonisolated func sessionDidExpire() async {
        await clearLocalSession()
    }

    private func clearLocalSession() {
        try? tokenStore.clear()
        user = nil
        bootError = nil
    }
}
