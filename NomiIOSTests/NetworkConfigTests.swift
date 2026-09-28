import Foundation
import Testing
@testable import Nomi

/// URL del backend configurable por compilación (`NOMI_API_BASE_URL`).
@Suite("NetworkConfig — URL del backend")
struct NetworkConfigTests {
    private func url(_ value: Any?) -> URL {
        NetworkConfig.apiBaseURL(from: value.map { [NetworkConfig.apiBaseURLInfoKey: $0] } ?? [:])
    }

    /// El caso del postest: el Mac por su nombre local, desde un iPhone físico.
    @Test func usesTheConfiguredURL() {
        #expect(url("http://mi-mac.local:8080/api") == URL(string: "http://mi-mac.local:8080/api")!)
        #expect(url("https://api.ejemplo.test/api") == URL(string: "https://api.ejemplo.test/api")!)
    }

    @Test func trimsSurroundingSpaces() {
        #expect(url("  http://mi-mac.local:8080/api ") == URL(string: "http://mi-mac.local:8080/api")!)
    }

    @Test func missingKeyFallsBackToTheDefault() {
        #expect(url(nil) == NetworkConfig.defaultAPIBaseURL)
        #expect(NetworkConfig.apiBaseURL(from: nil) == NetworkConfig.defaultAPIBaseURL)
    }

    /// Si la variable no llega a sustituirse, el Info.plist trae el texto literal.
    @Test func unresolvedBuildSettingFallsBackToTheDefault() {
        #expect(url("$(NOMI_API_BASE_URL)") == NetworkConfig.defaultAPIBaseURL)
    }

    @Test func invalidValuesFallBackToTheDefault() {
        #expect(url("") == NetworkConfig.defaultAPIBaseURL)
        #expect(url("ftp://mi-mac.local/api") == NetworkConfig.defaultAPIBaseURL)
        #expect(url("http://") == NetworkConfig.defaultAPIBaseURL)
        #expect(url("no es una url") == NetworkConfig.defaultAPIBaseURL)
        #expect(url(8080) == NetworkConfig.defaultAPIBaseURL)
    }

    /// Sin configuración local, Debug sigue apuntando a localhost, como antes.
    @Test func debugDefaultIsLocalhost() {
        #expect(NetworkConfig.defaultAPIBaseURL == URL(string: "http://localhost:8080/api")!)
    }
}
