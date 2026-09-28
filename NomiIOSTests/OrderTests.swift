import Foundation
import Testing
@testable import Nomi

/// Total cobrado y plazo para pagar de un pedido.
@Suite("Order")
struct OrderTests {
    /// Respuesta real de `POST /orders`: `total` es el subtotal de productos (4.00 + 6.00) y el
    /// pago cobró 10.00 + 2.00 + 0.50 + 0.20.
    private static let createdOrder = #"{"id":2,"userId":5,"storeId":1,"aulaId":1,"repartidorId":null,"items":[{"id":2,"productId":4,"productNombre":"Chicha Morada","productPrecio":4.00,"cantidad":1,"subtotal":4.00},{"id":3,"productId":6,"productNombre":"Alfajor Casero","productPrecio":3.00,"cantidad":2,"subtotal":6.00}],"total":10.00,"propina":2,"tarifaServicio":0.50,"comisionNomi":0.20,"status":"PENDIENTE","statusDescripcion":"Pendiente","notas":"Punto de encuentro: la puerta del salón","motivoCancelacion":null,"canceladoPor":null,"codigoConfirmacion":"5369","fotoEntregaUrl":null,"creadoEn":"2026-09-26T00:13:59.905824","actualizadoEn":"2026-09-26T00:13:59.905828"}"#

    @Test func chargedTotalAddsTipAndFeesToTheProductsSubtotal() throws {
        let order = try JSONDecoder.nomi.decode(Order.self, from: Data(Self.createdOrder.utf8))

        #expect(NMFormat.currency(order.total) == "S/ 10.00")
        #expect(NMFormat.currency(order.chargedTotal) == "S/ 12.70")
    }

    @Test func chargedTotalTreatsMissingChargesAsZero() throws {
        let json = Self.createdOrder
            .replacingOccurrences(of: #""propina":2"#, with: #""propina":null"#)
            .replacingOccurrences(of: #""tarifaServicio":0.50"#, with: #""tarifaServicio":null"#)
            .replacingOccurrences(of: #""comisionNomi":0.20"#, with: #""comisionNomi":null"#)
        let order = try JSONDecoder.nomi.decode(Order.self, from: Data(json.utf8))

        #expect(NMFormat.currency(order.chargedTotal) == "S/ 10.00")
    }

    @Test func paymentDeadlineCountsFromWhenTheResponseArrived() throws {
        let json = Self.createdOrder.replacingOccurrences(
            of: #""fotoEntregaUrl":null"#, with: #""fotoEntregaUrl":null,"segundosParaPagar":840"#)
        let order = try JSONDecoder.nomi.decode(Order.self, from: Data(json.utf8))
        let receivedAt = Date(timeIntervalSince1970: 1_000_000)

        #expect(order.segundosParaPagar == 840)
        #expect(order.paymentDeadline(receivedAt: receivedAt) == receivedAt.addingTimeInterval(840))
    }

    /// Pedidos anteriores a la regla de caducidad: el backend no manda el campo.
    @Test func orderWithoutDeadlineHasNoPaymentDeadline() throws {
        let order = try JSONDecoder.nomi.decode(Order.self, from: Data(Self.createdOrder.utf8))

        #expect(order.segundosParaPagar == nil)
        #expect(order.paymentDeadline(receivedAt: .now) == nil)
    }

    @Test func onlyPendingOrdersHaveAPaymentDeadline() throws {
        let json = Self.createdOrder
            .replacingOccurrences(of: #""status":"PENDIENTE""#, with: #""status":"PREPARANDO""#)
            .replacingOccurrences(of: #""fotoEntregaUrl":null"#, with: #""fotoEntregaUrl":null,"segundosParaPagar":840"#)
        let order = try JSONDecoder.nomi.decode(Order.self, from: Data(json.utf8))

        #expect(order.paymentDeadline(receivedAt: .now) == nil)
    }
}

/// Cuenta atrás del plazo para pagar en el seguimiento del pedido.
@Suite("OrderTrackingViewModel.stableDeadline")
struct PaymentDeadlineTests {
    private let base = Date(timeIntervalSince1970: 1_000_000)

    @Test func smallDriftBetweenPollsKeepsTheCurrentDeadline() {
        let reported = base.addingTimeInterval(1.4)
        #expect(OrderTrackingViewModel.stableDeadline(current: base, reported: reported) == base)
    }

    @Test func realChangeReplacesTheDeadline() {
        let reported = base.addingTimeInterval(-30)
        #expect(OrderTrackingViewModel.stableDeadline(current: base, reported: reported) == reported)
    }

    @Test func firstPollAndLostDeadlineFollowTheBackend() {
        #expect(OrderTrackingViewModel.stableDeadline(current: nil, reported: base) == base)
        #expect(OrderTrackingViewModel.stableDeadline(current: base, reported: nil) == nil)
    }
}
