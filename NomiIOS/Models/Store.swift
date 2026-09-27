import Foundation

/// Tienda del campus.
struct Store: Codable, Identifiable, Sendable {
    let id: Int
    let nombre: String
    let descripcion: String?
    let imagenUrl: String?
    let telefono: String?
    let ownerId: Int
    /// Si la tienda está habilitada en la plataforma; no refleja su horario de atención.
    let activo: Bool
    let creadoEn: Date?
    /// Hora en texto (`HH:mm`), tal como la guarda la tienda.
    let horarioApertura: String?
    let horarioCierre: String?
}
