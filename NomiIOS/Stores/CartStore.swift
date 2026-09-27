import Observation
import Foundation

/// Carrito del estudiante, en memoria.
///
/// Regla de negocio: todos los productos deben ser de la misma tienda, porque un pedido
/// pertenece a una sola tienda.
@MainActor
@Observable
final class CartStore: @unchecked Sendable {
    private(set) var items: [CartItem] = []
    private(set) var storeId: Int?
    private(set) var propina: Decimal = 0
    /// Salón del último pedido, para preseleccionarlo en el checkout.
    private(set) var lastAulaId: Int?

    /// Agrega el producto o suma la cantidad si ya estaba.
    /// - Returns: `false`, sin modificar el carrito, si el producto es de otra tienda. Quien
    ///   llama debe pedir al usuario que vacíe el carrito primero.
    @discardableResult
    func addItem(_ product: Product, cantidad: Int = 1) -> Bool {
        if let currentStoreId = storeId, currentStoreId != product.storeId, !items.isEmpty {
            return false
        }
        storeId = product.storeId
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].cantidad += cantidad
        } else {
            items.append(CartItem(product: product, cantidad: cantidad))
        }
        return true
    }

    /// Una cantidad de 0 o menos elimina la línea.
    func updateQuantity(productId: Int, cantidad: Int) {
        guard let index = items.firstIndex(where: { $0.product.id == productId }) else { return }
        if cantidad <= 0 {
            items.remove(at: index)
        } else {
            items[index].cantidad = cantidad
        }
        if items.isEmpty { storeId = nil }
        dropTipIfOverLimit()
    }

    func removeItem(productId: Int) {
        items.removeAll { $0.product.id == productId }
        if items.isEmpty { storeId = nil }
        dropTipIfOverLimit()
    }

    /// Ignora montos mayores que `maxPropina`: el backend rechazaría el pedido entero.
    func setPropina(_ amount: Decimal) {
        guard canTip(amount) else { return }
        propina = amount
    }

    /// Propina máxima: 50 % del subtotal de productos redondeado a céntimos (half-up), igual que
    /// `CreateOrderHandler` en el backend.
    var maxPropina: Decimal {
        var raw = subtotal * NMConstants.maxTipRatio
        var rounded = Decimal()
        NSDecimalRound(&rounded, &raw, 2, .plain)
        return rounded
    }

    func canTip(_ amount: Decimal) -> Bool {
        amount >= 0 && amount <= maxPropina
    }

    /// Vacía el carrito tras un pago iniciado. Conserva `lastAulaId` para el próximo pedido.
    func clear() {
        items = []
        storeId = nil
        propina = 0
    }

    /// Olvida todo, incluido el último salón. Se usa al cambiar de usuario o cerrar sesión: el
    /// carrito pertenece a quien lo llenó.
    func reset() {
        clear()
        lastAulaId = nil
    }

    /// Si el carrito se reduce por debajo de la propina elegida, la propina vuelve a 0.
    private func dropTipIfOverLimit() {
        if propina > maxPropina { propina = 0 }
    }

    func setLastAulaId(_ aulaId: Int) {
        lastAulaId = aulaId
    }

    /// Suma de precio × cantidad, sin tarifas ni propina.
    var subtotal: Decimal {
        items.reduce(Decimal(0)) { $0 + $1.product.precio * Decimal($1.cantidad) }
    }

    /// Unidades totales (para el contador del botón del carrito).
    var itemCount: Int {
        items.reduce(0) { $0 + $1.cantidad }
    }
}
