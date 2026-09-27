import Foundation
import Testing
@testable import Nomi

/// Lectura de la expiración del access token.
@Suite("JWT")
struct JWTTests {
    @Test func readsTheExpirationClaim() throws {
        let expiration = try #require(JWT.expirationDate(of: makeJWT(expiresIn: 120)))
        #expect(abs(expiration.timeIntervalSinceNow - 120) < 2)
    }

    @Test func expiredOrAboutToExpireCountsAsExpired() {
        #expect(JWT.isExpired(makeJWT(expiresIn: -5), leeway: 60))
        #expect(JWT.isExpired(makeJWT(expiresIn: 30), leeway: 60))
        #expect(!JWT.isExpired(makeJWT(expiresIn: 3600), leeway: 60))
    }

    /// `e30` es `{}` en base64url: un token bien formado sin `exp`.
    @Test(arguments: ["", "abc", "a.b", "a.%%%.c", "a.e30.c"])
    func unreadableTokensFallBackToTheReactivePath(token: String) {
        #expect(JWT.expirationDate(of: token) == nil)
        #expect(!JWT.isExpired(token, leeway: 60))
    }
}
