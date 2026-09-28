import Foundation

/// Línea de un pedido. Nombre y precio son una copia del producto en el momento de pedir.
struct OrderItem: Codable, Identifiable, Sendable {
    let id: Int
    let productId: Int
    let productNombre: String
    let productPrecio: Decimal
    let cantidad: Int
    let subtotal: Decimal
}

/// Estados del pedido. Transiciones válidas (las aplica el backend):
/// `PENDIENTE → PREPARANDO → LISTO_PARA_RECOGER → EN_CAMINO → ENTREGADO`, y
/// `PENDIENTE → CANCELADO`. El paso a `PREPARANDO` lo hace el backend al aprobarse el pago
/// (webhook o conciliación). Un pedido que no se paga dentro de su plazo se cancela solo.
enum OrderStatus: String, Codable, Sendable {
    case pendiente = "PENDIENTE"
    case preparando = "PREPARANDO"
    case listoParaRecoger = "LISTO_PARA_RECOGER"
    case enCamino = "EN_CAMINO"
    case entregado = "ENTREGADO"
    case cancelado = "CANCELADO"
}

/// Pedido tal como lo devuelve el backend.
struct Order: Codable, Identifiable, Sendable {
    let id: Int
    let userId: Int
    let storeId: Int
    let aulaId: Int
    let repartidorId: Int?
    let items: [OrderItem]
    /// Solo el subtotal de productos: no incluye propina, tarifa ni comisión. Para lo que paga
    /// el estudiante usar `chargedTotal`.
    let total: Decimal
    let propina: Decimal?
    let tarifaServicio: Decimal?
    let comisionNomi: Decimal?
    let status: OrderStatus
    let statusDescripcion: String?
    let notas: String?
    let motivoCancelacion: String?
    let canceladoPor: Int?
    /// Código de 4 dígitos que el estudiante muestra al recibir el pedido.
    let codigoConfirmacion: String?
    let fotoEntregaUrl: String?
    /// Segundos que quedaban para pagar cuando respondió el backend; `nil` si el pedido ya no
    /// está pendiente o es anterior a la regla de caducidad. Es relativo a propósito: las fechas
    /// del backend no llevan zona y el reloj del teléfono puede ir desfasado.
    let segundosParaPagar: Int?
    let creadoEn: Date?
    let actualizadoEn: Date?

    /// Lo que paga el estudiante: subtotal + propina + tarifa de servicio + comisión Nomi. Es
    /// la misma suma con la que el backend calcula el monto del pago.
    var chargedTotal: Decimal {
        total + (propina ?? 0) + (tarifaServicio ?? 0) + (comisionNomi ?? 0)
    }

    /// Momento, en el reloj del teléfono, en que vence el plazo para pagar, contado desde que
    /// llegó la respuesta. `nil` si el pedido no espera pago o no tiene plazo.
    func paymentDeadline(receivedAt: Date) -> Date? {
        guard status == .pendiente, let segundosParaPagar else { return nil }
        return receivedAt.addingTimeInterval(TimeInterval(max(0, segundosParaPagar)))
    }
}

/// Cuerpo de `POST /orders`. Todos los productos deben ser de `storeId`.
struct CreateOrderRequest: Codable, Sendable {
    struct Item: Codable, Sendable {
        let productId: Int
        let cantidad: Int
    }
    let storeId: Int
    let aulaId: Int
    let items: [Item]
    let notas: String?
    let propina: Decimal?
}
