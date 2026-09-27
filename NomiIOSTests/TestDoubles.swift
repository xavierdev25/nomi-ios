import Foundation
import Testing
@testable import Nomi

/// Sustituto en memoria de `KeychainTokenStore`.
final class InMemoryTokenStore: TokenStoring, @unchecked Sendable {
    private let lock = NSLock()
    private var tokens: AuthTokens?

    init(_ tokens: AuthTokens?) {
        self.tokens = tokens
    }

    func currentTokens() throws -> AuthTokens? { lock.withLock { tokens } }
    func save(_ tokens: AuthTokens) throws { lock.withLock { self.tokens = tokens } }
    func clear() throws { lock.withLock { tokens = nil } }
}

/// Cuenta cuántas veces se avisó de que la sesión expiró.
final class SessionExpirySpy: SessionExpiring, @unchecked Sendable {
    private let lock = NSLock()
    private var calls = 0

    var callCount: Int { lock.withLock { calls } }

    func sessionDidExpire() async {
        lock.withLock { calls += 1 }
    }
}

/// JWT sin firmar con los claims que lee `JWT`. El `jti` aleatorio hace cada token distinto.
func makeJWT(expiresIn seconds: TimeInterval) -> String {
    func base64URL(_ json: String) -> String {
        Data(json.utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    let exp = Int(Date.now.timeIntervalSince1970 + seconds)
    let header = base64URL(#"{"alg":"HS256","typ":"JWT"}"#)
    let payload = base64URL(#"{"sub":"ana@test.local","jti":"\#(UUID().uuidString)","exp":\#(exp)}"#)
    return "\(header).\(payload).firma"
}

/// Suite padre de todas las que usan `StubURLProtocol`. Su estado es estático y las suites
/// hermanas corren en paralelo: `.serialized` en el padre las cubre a todas.
@Suite(.serialized)
enum StubbedNetwork {
    static let baseURL = URL(string: "https://api.test/api")!

    /// La pila de red real (`APIClient` + `TokenRefresher`) sobre una sesión simulada.
    static func makeClient(store: TokenStoring, spy: SessionExpiring) -> APIClient {
        let session = StubURLProtocol.makeSession()
        let refresher = TokenRefresher(tokenStore: store, baseURL: baseURL, session: session)
        return APIClient(baseURL: baseURL, session: session, tokenStore: store, refresher: refresher, onSessionExpired: spy)
    }
}

/// Responde cada petición de una `URLSession` simulada con `handler` y registra lo enviado.
/// Usar solo desde suites anidadas en `StubbedNetwork`.
final class StubURLProtocol: URLProtocol {
    struct Recorded: Sendable {
        let path: String
        let method: String?
        let authorization: String?
        let body: Data?
    }

    typealias Handler = @Sendable (URLRequest) throws -> (status: Int, body: String)

    private static let lock = NSLock()
    nonisolated(unsafe) private static var handler: Handler?
    nonisolated(unsafe) private static var recorded: [Recorded] = []

    static func reset(handler: @escaping Handler) {
        lock.withLock {
            self.handler = handler
            recorded = []
        }
    }

    static var requests: [Recorded] { lock.withLock { recorded } }

    static func requests(to pathSuffix: String) -> [Recorded] {
        requests.filter { $0.path.hasSuffix(pathSuffix) }
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let recorded = Recorded(
            path: request.url?.path ?? "",
            method: request.httpMethod,
            authorization: request.value(forHTTPHeaderField: "Authorization"),
            body: request.httpBody ?? request.httpBodyStream.map(Self.readAll)
        )
        let handler = Self.lock.withLock {
            Self.recorded.append(recorded)
            return Self.handler
        }
        do {
            guard let handler else { throw URLError(.unknown) }
            let (status, body) = try handler(request)
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: status,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: Data(body.utf8))
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    /// `URLSession` entrega el cuerpo a los protocolos como stream, no en `httpBody`.
    private static func readAll(_ stream: InputStream) -> Data {
        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: buffer.count)
            guard read > 0 else { break }
            data.append(buffer, count: read)
        }
        return data
    }
}
