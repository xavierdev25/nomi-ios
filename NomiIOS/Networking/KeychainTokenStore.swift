import Foundation
import Security

/// Par de tokens de la sesión.
struct AuthTokens: Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
}

/// Almacenamiento de tokens. Protocolo para poder sustituir el Keychain en los tests.
protocol TokenStoring: Sendable {
    func currentTokens() throws -> AuthTokens?
    func save(_ tokens: AuthTokens) throws
    func clear() throws
}

/// Guarda los tokens en el Keychain como contraseñas genéricas del servicio
/// `com.nomi.ios.tokens`, con la accesibilidad por defecto (disponibles con el
/// dispositivo desbloqueado).
///
/// Los elementos del Keychain sobreviven a la desinstalación de la app: al reinstalarla, la
/// sesión anterior se recupera si sus tokens siguen vigentes.
final class KeychainTokenStore: TokenStoring, Sendable {
    private let service = "com.nomi.ios.tokens"
    private let accessAccount = "accessToken"
    private let refreshAccount = "refreshToken"

    func currentTokens() throws -> AuthTokens? {
        guard let access = try read(account: accessAccount),
              let refresh = try read(account: refreshAccount) else {
            return nil
        }
        return AuthTokens(accessToken: access, refreshToken: refresh)
    }

    func save(_ tokens: AuthTokens) throws {
        try write(tokens.accessToken, account: accessAccount)
        try write(tokens.refreshToken, account: refreshAccount)
    }

    func clear() throws {
        try delete(account: accessAccount)
        try delete(account: refreshAccount)
    }

    private func read(account: String) throws -> String? {
        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unhandled(status)
        }
        return String(data: data, encoding: .utf8)
    }

    /// Actualiza el elemento si existe y lo crea si no.
    private func write(_ value: String, account: String) throws {
        let data = Data(value.utf8)
        var query = baseQuery(account: account)

        let attributes: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        if updateStatus == errSecItemNotFound {
            query[kSecValueData as String] = data
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else { throw KeychainError.unhandled(addStatus) }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.unhandled(updateStatus)
        }
    }

    private func delete(account: String) throws {
        let query = baseQuery(account: account)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status)
        }
    }

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

/// Código de error de Security.framework no esperado.
enum KeychainError: Error {
    case unhandled(OSStatus)
}
