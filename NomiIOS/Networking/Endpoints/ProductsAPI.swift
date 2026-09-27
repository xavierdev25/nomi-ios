import Foundation

/// Catálogo de productos.
struct ProductsAPI: Sendable {
    let client: APIClient

    /// Filtros de búsqueda; los `nil` no se envían. `categoria` usa los valores del backend
    /// (`COMIDA`, `BEBIDA`, `SNACK`, `POSTRE`, `OTRO`).
    struct SearchParams: Sendable {
        var nombre: String?
        var categoria: String?
        var storeId: Int?
        var disponible: Bool?
        var page: Int?
        var size: Int?
    }

    /// Búsqueda paginada, ordenada por nombre. Solo devuelve productos activos.
    func search(_ params: SearchParams) async throws -> PageResponse<Product> {
        let query: [String: String?] = [
            "nombre": params.nombre,
            "categoria": params.categoria,
            "storeId": params.storeId.map(String.init),
            "disponible": params.disponible.map(String.init),
            "page": params.page.map(String.init),
            "size": params.size.map(String.init),
        ]
        let endpoint = APIEndpoint(path: "products/search", method: .get, query: query)
        return try await client.send(endpoint)
    }

    func get(id: Int) async throws -> Product {
        try await client.send(APIEndpoint(path: "products/\(id)", method: .get))
    }
}
