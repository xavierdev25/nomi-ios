import Foundation

/// Producto del catálogo de una tienda.
struct Product: Codable, Identifiable, Sendable {
    let id: Int
    let nombre: String
    let descripcion: String?
    let precio: Decimal
    let stock: Int
    let imagenUrl: String?
    /// Valor del enum del backend (`COMIDA`, `BEBIDA`, `SNACK`, `POSTRE`, `OTRO`); para mostrarlo
    /// usar `NMFormat.category(_:)`.
    let categoria: String
    let storeId: Int
    let activo: Bool
    /// `false` si se agotó o la tienda lo pausó. `activo` indica si está publicado.
    let disponible: Bool
    let creadoEn: Date?
}
