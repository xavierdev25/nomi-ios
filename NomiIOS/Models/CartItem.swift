import Foundation

/// Línea del carrito. Solo existe en el cliente; no es un DTO del backend.
struct CartItem: Codable, Identifiable, Sendable {
    var id: Int { product.id }
    let product: Product
    var cantidad: Int
}
