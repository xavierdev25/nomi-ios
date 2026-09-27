import Foundation
import Testing
@testable import Nomi

/// Límite de propina de `CartStore`, que debe coincidir con `CreateOrderHandler` del backend.
@Suite("CartStore — propina")
@MainActor
struct CartStoreTests {
    private func product(id: Int, precio: String, storeId: Int = 1) -> Product {
        Product(
            id: id, nombre: "P\(id)", descripcion: nil, precio: Decimal(string: precio)!, stock: 50,
            imagenUrl: nil, categoria: "COMIDA", storeId: storeId, activo: true, disponible: true, creadoEn: nil
        )
    }

    @Test func maxTipIsHalfTheSubtotalRoundedHalfUpLikeTheBackend() {
        let cart = CartStore()
        cart.addItem(product(id: 1, precio: "4.00"))
        #expect(cart.maxPropina == Decimal(string: "2.00"))

        cart.addItem(product(id: 2, precio: "8.25"))
        #expect(cart.maxPropina == Decimal(string: "6.13"))
    }

    /// El caso que falló en vivo: propina de S/ 5 en un carrito de S/ 4 → `POST /orders` 400.
    @Test func tipOverTheLimitIsIgnored() {
        let cart = CartStore()
        cart.addItem(product(id: 1, precio: "4.00"))

        cart.setPropina(5)
        #expect(cart.propina == 0)
        #expect(!cart.canTip(5))

        cart.setPropina(2)
        #expect(cart.propina == 2)
    }

    @Test func shrinkingTheCartBelowTheTipDropsTheTip() {
        let cart = CartStore()
        cart.addItem(product(id: 1, precio: "4.00"), cantidad: 2)
        cart.setPropina(3)

        cart.updateQuantity(productId: 1, cantidad: 1)

        #expect(cart.propina == 0)
    }

    @Test func resetForgetsEverythingFromThePreviousUser() {
        let cart = CartStore()
        cart.addItem(product(id: 1, precio: "4.00"))
        cart.setPropina(1)
        cart.setLastAulaId(7)

        cart.reset()

        #expect(cart.items.isEmpty)
        #expect(cart.storeId == nil)
        #expect(cart.propina == 0)
        #expect(cart.lastAulaId == nil)
    }

    @Test func clearAfterPaymentKeepsTheLastAula() {
        let cart = CartStore()
        cart.addItem(product(id: 1, precio: "4.00"))
        cart.setLastAulaId(7)

        cart.clear()

        #expect(cart.items.isEmpty)
        #expect(cart.lastAulaId == 7)
    }
}
