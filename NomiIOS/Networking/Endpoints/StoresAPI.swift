import Foundation

/// Tiendas del campus. Solo `get(id:)` está en uso; `search` y `list` quedan disponibles
/// para una futura pantalla de tiendas.
struct StoresAPI: Sendable {
    let client: APIClient

    func search(nombre: String = "", page: Int = 0, size: Int = 20) async throws -> PageResponse<Store> {
        let endpoint = APIEndpoint(
            path: "stores/search",
            method: .get,
            query: ["nombre": nombre, "page": String(page), "size": String(size)]
        )
        return try await client.send(endpoint)
    }

    func list(page: Int = 0, size: Int = 20) async throws -> PageResponse<Store> {
        let endpoint = APIEndpoint(path: "stores", method: .get, query: ["page": String(page), "size": String(size)])
        return try await client.send(endpoint)
    }

    func get(id: Int) async throws -> Store {
        try await client.send(APIEndpoint(path: "stores/\(id)", method: .get))
    }
}
