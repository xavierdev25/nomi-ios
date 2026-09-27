import Foundation

/// Pagos con MercadoPago. El monto lo calcula el servidor a partir del pedido: el cliente
/// solo indica qué pedido paga.
struct PaymentsAPI: Sendable {
    let client: APIClient

    /// Único campo del cuerpo: no existe `backUrl` ni monto.
    struct CreateRequest: Codable, Sendable {
        let orderId: Int
    }

    func create(orderId: Int) async throws -> PaymentResponse {
        let endpoint = try APIEndpoint.encoding(CreateRequest(orderId: orderId), path: "payments", method: .post)
        return try await client.send(endpoint)
    }

    /// - Throws: `APIError.server` con estado 404 si el pedido todavía no tiene pago.
    func byOrder(orderId: Int) async throws -> PaymentResponse {
        try await client.send(APIEndpoint(path: "payments/order/\(orderId)", method: .get))
    }

    func me() async throws -> [PaymentResponse] {
        try await client.send(APIEndpoint(path: "payments/me", method: .get))
    }

    /// URL de pago de MercadoPago para un pedido, reutilizando su pago si ya existe.
    ///
    /// El backend rechaza un segundo `POST /payments` para el mismo pedido. Crear siempre
    /// fallaba para siempre si una creación anterior había llegado al servidor pero su respuesta
    /// se perdió, y un pedido sin pagar ya no se podía volver a pagar.
    func checkoutURL(forOrder orderId: Int) async throws -> URL {
        let payment: PaymentResponse
        do {
            payment = try await byOrder(orderId: orderId)
        } catch APIError.server(_, statusCode: 404) {
            payment = try await create(orderId: orderId)
        }
        guard let url = URL(string: payment.paymentUrl) else { throw APIError.invalidResponse }
        return url
    }
}
