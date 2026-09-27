import Foundation

/// Pago de un pedido en MercadoPago.
struct PaymentResponse: Codable, Identifiable, Sendable {
    let id: Int
    let orderId: Int
    let userId: Int
    let amount: Decimal
    /// `PENDIENTE`, `APROBADO`, `RECHAZADO`, `CANCELADO` o `REEMBOLSADO`. Lo actualiza el webhook
    /// de MercadoPago, no el cliente.
    let status: String
    let externalId: String
    /// URL del checkout de MercadoPago donde el estudiante completa el pago.
    let paymentUrl: String
    let failureReason: String?
    let creadoEn: Date?
    let actualizadoEn: Date?

    /// `true` cuando MercadoPago confirmó el pago.
    var isApproved: Bool { status == "APROBADO" }
}
