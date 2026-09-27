import Foundation

/// Relación usuario-producto favorito, tal como la devuelve el alta.
struct FavoriteProduct: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int
    let productId: Int
    let creadoEn: Date?
}

/// Relación usuario-tienda favorita, tal como la devuelve el alta.
struct FavoriteStore: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int
    let storeId: Int
    let creadoEn: Date?
}
