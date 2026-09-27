import Foundation

/// Perfil de verificación de un repartidor. Ninguna pantalla lo usa todavía: queda para
/// cuando exista el flujo de repartidor.
struct RepartidorPerfil: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int
    let dni: String
    let fotoRostroUrl: String?
    let fotoDniFrontalUrl: String?
    let fotoDniPosteriorUrl: String?
    let contactoEmergenciaNombre: String?
    let contactoEmergenciaTelefono: String?
    let estadoVerificacion: String
    let motivoRechazo: String?
    let activo: Bool
    let rating: Double
    let totalEntregas: Int
    let totalCancelaciones: Int
    let creadoEn: Date?
}
