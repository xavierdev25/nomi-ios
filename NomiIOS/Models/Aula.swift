import Foundation

/// Salón del campus donde se entrega un pedido.
struct Aula: Codable, Identifiable, Sendable {
    let id: Int
    let codigo: String
    let nombre: String
    let piso: String?
    let pabellon: String?
    let activo: Bool
}
