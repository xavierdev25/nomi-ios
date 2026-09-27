import Foundation
import Testing
@testable import Nomi

/// Total cobrado de un pedido.
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
}
