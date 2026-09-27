import Foundation

/// Página de resultados con la forma propia del backend (no el `Page` por defecto de Spring).
/// `currentPage` empieza en 0.
struct PageResponse<T: Codable & Sendable>: Codable, Sendable {
    let content: [T]
    let totalElements: Int
    let totalPages: Int
    let currentPage: Int
    let pageSize: Int
}
