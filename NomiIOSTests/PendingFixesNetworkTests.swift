import Foundation
import Testing
@testable import Nomi

private let meBody = #"{"id":5,"nombres":"Ana","apellidos":null,"email":"ana@test.local","telefono":null,"role":"ESTUDIANTE","esRepartidor":null,"campusId":null,"activo":true,"creadoEn":null,"preferences":null,"restrictions":null,"budgetRange":null,"cuisineTypes":null}"#

private func paymentBody(status: String, url: String = "https://mp.test/checkout/pref-1") -> String {
    #"{"id":9,"orderId":3,"userId":5,"amount":6.70,"status":"\#(status)","externalId":"pref-1","paymentUrl":"\#(url)","failureReason":null,"creadoEn":null,"actualizadoEn":null}"#
}

extension StubbedNetwork {
    /// `PaymentsAPI.checkoutURL` reutiliza el pago existente del pedido.
    @Suite("PaymentsAPI — reutilizar el pago del pedido")
    struct PaymentsCheckoutTests {
        private func makeAPI() -> PaymentsAPI {
            let store = InMemoryTokenStore(AuthTokens(accessToken: makeJWT(expiresIn: 3600), refreshToken: "r1"))
            return PaymentsAPI(client: StubbedNetwork.makeClient(store: store, spy: SessionExpirySpy()))
        }

        /// Reintento tras una creación cuya respuesta se perdió: el backend ya tiene el pago y
        /// rechaza un segundo `POST` con "Ya existe un pago para esta orden".
        @Test func existingPaymentIsReusedWithoutCreatingAnother() async throws {
            StubURLProtocol.reset { request in
                if request.httpMethod == "POST" { return (400, #"{"message":"Ya existe un pago para esta orden"}"#) }
                return (200, paymentBody(status: "PENDIENTE"))
            }

            let url = try await makeAPI().checkoutURL(forOrder: 3)

            #expect(url.absoluteString == "https://mp.test/checkout/pref-1")
            #expect(StubURLProtocol.requests.map(\.method) == ["GET"])
        }

        @Test func missingPaymentIsCreated() async throws {
            StubURLProtocol.reset { request in
                if request.httpMethod == "GET" { return (404, #"{"message":"Pago no encontrado para esta orden"}"#) }
                return (201, paymentBody(status: "PENDIENTE", url: "https://mp.test/checkout/nuevo"))
            }

            let url = try await makeAPI().checkoutURL(forOrder: 3)

            #expect(url.absoluteString == "https://mp.test/checkout/nuevo")
            #expect(StubURLProtocol.requests.map(\.method) == ["GET", "POST"])
            #expect(StubURLProtocol.requests.last?.path.hasSuffix("/payments") == true)
        }
    }

    /// Arranque y cierre de sesión de `AuthStore`.
    @Suite("AuthStore — arranque y logout")
    @MainActor
    struct AuthStoreSessionTests {
        private func makeStore(tokens: AuthTokens?) -> (AuthStore, InMemoryTokenStore) {
            let tokenStore = InMemoryTokenStore(tokens)
            let authStore = AuthStore(tokenStore: tokenStore)
            authStore.authAPI = AuthAPI(client: StubbedNetwork.makeClient(store: tokenStore, spy: authStore))
            return (authStore, tokenStore)
        }

        /// Regresión: abrir la app sin conexión borraba los tokens y devolvía al login.
        @Test func offlineLaunchKeepsTheSessionAndOffersARetry() async throws {
            let tokens = AuthTokens(accessToken: makeJWT(expiresIn: 3600), refreshToken: "r1")
            let (authStore, tokenStore) = makeStore(tokens: tokens)
            StubURLProtocol.reset { _ in throw URLError(.notConnectedToInternet) }

            await authStore.bootstrap()

            #expect(authStore.user == nil)
            #expect(authStore.bootError == "No se pudo conectar. Revisa tu conexión.")
            #expect(try tokenStore.currentTokens() == tokens)

            StubURLProtocol.reset { _ in (200, meBody) }
            await authStore.bootstrap()

            #expect(authStore.user?.nombres == "Ana")
            #expect(authStore.bootError == nil)
        }

        @Test func rejectedSessionOnLaunchClearsTheTokens() async throws {
            let (authStore, tokenStore) = makeStore(tokens: AuthTokens(accessToken: makeJWT(expiresIn: -10), refreshToken: "revocado"))
            StubURLProtocol.reset { _ in (400, #"{"message":"Refresh token revocado"}"#) }

            await authStore.bootstrap()

            #expect(authStore.user == nil)
            #expect(authStore.bootError == nil)
            #expect(try tokenStore.currentTokens() == nil)
        }

        @Test func logoutClearsLocallyAndRevokesServerSide() async throws {
            let access = makeJWT(expiresIn: 3600)
            let (authStore, tokenStore) = makeStore(tokens: AuthTokens(accessToken: access, refreshToken: "r1"))
            StubURLProtocol.reset { request in
                request.url!.path.hasSuffix("auth/logout") ? (200, #"{"message":"Sesión cerrada exitosamente"}"#) : (200, meBody)
            }
            await authStore.bootstrap()

            authStore.logout()

            #expect(authStore.user == nil)
            #expect(try tokenStore.currentTokens() == nil)
            let logout = try await waitForRequest(to: "auth/logout")
            #expect(logout.method == "POST")
            #expect(logout.authorization == "Bearer \(access)")
            let body = try #require(logout.body)
            #expect(String(decoding: body, as: UTF8.self).contains(#""refreshToken":"r1""#))
        }

        /// `logout()` revoca en una tarea independiente: se espera a que salga la petición.
        private func waitForRequest(to pathSuffix: String) async throws -> StubURLProtocol.Recorded {
            for _ in 0..<100 {
                if let request = StubURLProtocol.requests(to: pathSuffix).first { return request }
                try await Task.sleep(nanoseconds: 20_000_000)
            }
            throw URLError(.timedOut)
        }
    }
}
