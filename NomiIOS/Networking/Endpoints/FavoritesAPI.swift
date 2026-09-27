import Foundation

/// Productos y tiendas favoritos del usuario.
struct FavoritesAPI: Sendable {
    let client: APIClient

    func products() async throws -> [Product] {
        try await client.send(APIEndpoint(path: "favorites/products", method: .get))
    }

    func addProduct(_ productId: Int) async throws {
        let endpoint = APIEndpoint(path: "favorites/products/\(productId)", method: .post)
        let _: FavoriteProduct = try await client.send(endpoint)
    }

    func removeProduct(_ productId: Int) async throws {
        try await client.sendNoContent(APIEndpoint(path: "favorites/products/\(productId)", method: .delete))
    }

    /// Consulta `/check` en lugar de descargar la lista completa solo para pintar un corazón.
    func isProductFavorite(_ productId: Int) async throws -> Bool {
        let response: FavoriteCheckResponse = try await client.send(
            APIEndpoint(path: "favorites/products/\(productId)/check", method: .get)
        )
        return response.favorite
    }

    func stores() async throws -> [Store] {
        try await client.send(APIEndpoint(path: "favorites/stores", method: .get))
    }

    func addStore(_ storeId: Int) async throws {
        let endpoint = APIEndpoint(path: "favorites/stores/\(storeId)", method: .post)
        let _: FavoriteStore = try await client.send(endpoint)
    }

    func removeStore(_ storeId: Int) async throws {
        try await client.sendNoContent(APIEndpoint(path: "favorites/stores/\(storeId)", method: .delete))
    }

    /// Consulta `/check` en lugar de descargar la lista completa solo para pintar un corazón.
    func isStoreFavorite(_ storeId: Int) async throws -> Bool {
        let response: FavoriteCheckResponse = try await client.send(
            APIEndpoint(path: "favorites/stores/\(storeId)/check", method: .get)
        )
        return response.favorite
    }
}

/// Respuesta de los endpoints `/check`.
struct FavoriteCheckResponse: Codable, Sendable {
    let favorite: Bool
}
