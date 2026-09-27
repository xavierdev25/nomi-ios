import Foundation
import Testing
@testable import Nomi

extension StubbedNetwork {
    /// Renovación de sesión de `APIClient` + `TokenRefresher` contra un backend simulado.
    @Suite("APIClient — renovación de sesión")
    struct APIClientSessionTests {
        /// Respuesta real de `GET /users/me`, capturada del backend local.
        private static let meBody = #"{"id":5,"nombres":"Ana","apellidos":null,"email":"ana@test.local","telefono":null,"role":"ESTUDIANTE","esRepartidor":null,"campusId":null,"activo":true,"creadoEn":null,"preferences":null,"restrictions":null,"budgetRange":null,"cuisineTypes":null}"#

        /// Lo que respondía el backend a un token expirado antes de que `SecurityConfig` tuviera su
        /// entry point de 401. La renovación preventiva debe funcionar igual.
        private static let forbiddenBody = #"{"status":403,"error":"Forbidden","message":"Forbidden"}"#

        private static func refreshBody(access: String, refresh: String) -> String {
            #"{"accessToken":"\#(access)","refreshToken":"\#(refresh)","tokenType":"Bearer","expiresIn":86400000}"#
        }

        private static func isRefresh(_ request: URLRequest) -> Bool {
            request.url?.path.hasSuffix("auth/refresh") == true
        }

        private func makeAuthAPI(store: InMemoryTokenStore, spy: SessionExpirySpy) -> AuthAPI {
            AuthAPI(client: StubbedNetwork.makeClient(store: store, spy: spy))
        }

        @Test func expiredAccessTokenIsRefreshedBeforeTheRequest() async throws {
            let fresh = makeJWT(expiresIn: 3600)
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "r1"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { return (200, Self.refreshBody(access: fresh, refresh: "r2")) }
                guard request.value(forHTTPHeaderField: "Authorization") == "Bearer \(fresh)" else {
                    return (403, Self.forbiddenBody)
                }
                return (200, Self.meBody)
            }

            let user = try await makeAuthAPI(store: store, spy: spy).me()

            #expect(user.nombres == "Ana")
            #expect(StubURLProtocol.requests(to: "auth/refresh").count == 1)
            #expect(StubURLProtocol.requests(to: "users/me").map(\.authorization) == ["Bearer \(fresh)"])
            #expect(try store.currentTokens()?.refreshToken == "r2")
            #expect(spy.callCount == 0)
        }

        @Test func unauthorizedResponseRefreshesAndRetriesOnce() async throws {
            let stale = makeJWT(expiresIn: 3600)
            let fresh = makeJWT(expiresIn: 3600)
            let store = InMemoryTokenStore(AuthTokens(accessToken: stale, refreshToken: "r1"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { return (200, Self.refreshBody(access: fresh, refresh: "r2")) }
                let isFresh = request.value(forHTTPHeaderField: "Authorization") == "Bearer \(fresh)"
                return isFresh ? (200, Self.meBody) : (401, #"{"status":401}"#)
            }

            _ = try await makeAuthAPI(store: store, spy: spy).me()

            #expect(StubURLProtocol.requests(to: "users/me").map(\.authorization) == ["Bearer \(stale)", "Bearer \(fresh)"])
            #expect(StubURLProtocol.requests(to: "auth/refresh").count == 1)
            #expect(spy.callCount == 0)
        }

        @Test func rejectedRefreshTokenEndsTheSession() async throws {
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "revocado"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) {
                    return (400, #"{"error":"Solicitud inválida","message":"Refresh token revocado","status":400}"#)
                }
                return (200, Self.meBody)
            }

            do {
                _ = try await makeAuthAPI(store: store, spy: spy).me()
                Issue.record("Se esperaba APIError.unauthorized")
            } catch APIError.unauthorized {}

            #expect(spy.callCount == 1)
            #expect(StubURLProtocol.requests(to: "users/me").isEmpty)
        }

        /// Regresión: un fallo de red al renovar cerraba la sesión.
        @Test func networkFailureDuringRefreshKeepsTheSession() async throws {
            let tokens = AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "r1")
            let store = InMemoryTokenStore(tokens)
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { throw URLError(.notConnectedToInternet) }
                return (200, Self.meBody)
            }

            do {
                _ = try await makeAuthAPI(store: store, spy: spy).me()
                Issue.record("Se esperaba APIError.transport")
            } catch APIError.transport {}

            #expect(spy.callCount == 0)
            #expect(try store.currentTokens() == tokens)
        }

        @Test func serverErrorDuringRefreshKeepsTheSession() async throws {
            let tokens = AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "r1")
            let store = InMemoryTokenStore(tokens)
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { return (500, #"{"status":500,"message":"Ocurrió un error inesperado."}"#) }
                return (200, Self.meBody)
            }

            do {
                _ = try await makeAuthAPI(store: store, spy: spy).me()
                Issue.record("Se esperaba APIError.server")
            } catch APIError.server {}

            #expect(spy.callCount == 0)
            #expect(try store.currentTokens() == tokens)
        }

        @Test func unauthorizedRightAfterRefreshEndsTheSessionWithoutLooping() async throws {
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "r1"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { return (200, Self.refreshBody(access: makeJWT(expiresIn: 3600), refresh: "r2")) }
                return (401, #"{"status":401}"#)
            }

            do {
                _ = try await makeAuthAPI(store: store, spy: spy).me()
                Issue.record("Se esperaba APIError.unauthorized")
            } catch APIError.unauthorized {}

            #expect(StubURLProtocol.requests(to: "auth/refresh").count == 1)
            #expect(StubURLProtocol.requests(to: "users/me").count == 1)
            #expect(spy.callCount == 1)
        }

        /// Inicio lanza productos y recomendaciones a la vez al arrancar: con el token vencido deben
        /// compartir una única renovación, porque el backend rota el refresh token en cada uso.
        @Test func concurrentRequestsShareASingleRefresh() async throws {
            let fresh = makeJWT(expiresIn: 3600)
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "r1"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { request in
                if Self.isRefresh(request) { return (200, Self.refreshBody(access: fresh, refresh: "r2")) }
                let isFresh = request.value(forHTTPHeaderField: "Authorization") == "Bearer \(fresh)"
                return isFresh ? (200, Self.meBody) : (403, Self.forbiddenBody)
            }
            let api = makeAuthAPI(store: store, spy: spy)

            try await withThrowingTaskGroup(of: User.self) { group in
                for _ in 0..<5 {
                    group.addTask { try await api.me() }
                }
                for try await _ in group {}
            }

            #expect(StubURLProtocol.requests(to: "auth/refresh").count == 1)
            #expect(StubURLProtocol.requests(to: "users/me").count == 5)
            #expect(spy.callCount == 0)
        }

        /// Regresión: el pull-to-refresh mostraba "No se pudo conectar" al cancelarse su tarea.
        @Test func cancelledRequestIsNotReportedAsAConnectionError() async throws {
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: 3600), refreshToken: "r1"))
            let spy = SessionExpirySpy()
            StubURLProtocol.reset { _ in throw URLError(.cancelled) }

            await #expect(throws: CancellationError.self) {
                _ = try await makeAuthAPI(store: store, spy: spy).me()
            }
        }
    }
}
