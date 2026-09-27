import Foundation

/// Pedidos del estudiante.
struct OrdersAPI: Sendable {
    let client: APIClient

    /// Crea el pedido en `PENDIENTE` y reserva el stock. El total cobrado y las tarifas los
    /// calcula el servidor; el cliente solo envía productos, cantidades, salón, notas y propina.
    func create(_ request: CreateOrderRequest) async throws -> Order {
        let endpoint = try APIEndpoint.encoding(request, path: "orders", method: .post)
        return try await client.send(endpoint)
    }

    /// Pedidos del usuario, del más reciente al más antiguo.
    func me(page: Int = 0, size: Int = 20) async throws -> PageResponse<Order> {
        let endpoint = APIEndpoint(
            path: "orders/me",
            method: .get,
            query: ["page": String(page), "size": String(size), "sortBy": "id"]
        )
        return try await client.send(endpoint)
    }

    func get(id: Int) async throws -> Order {
        try await client.send(APIEndpoint(path: "orders/\(id)", method: .get))
    }

    /// Historial de cambios de estado. Hoy ninguna pantalla lo usa, y el backend solo registra
    /// los cambios hechos con `PATCH /orders/{id}/status`.
    func history(orderId: Int) async throws -> [OrderStatusHistoryEntry] {
        try await client.send(APIEndpoint(path: "orders/\(orderId)/history", method: .get))
    }

    /// Solo se puede cancelar en `PENDIENTE`; en otro estado el backend responde 400. Devuelve
    /// el stock reservado.
    func cancel(id: Int, motivo: String?) async throws -> Order {
        let endpoint = try APIEndpoint.encoding(CancelOrderRequest(motivo: motivo), path: "orders/\(id)/cancel", method: .patch)
        return try await client.send(endpoint)
    }
}

/// Cuerpo de `PATCH /orders/{id}/cancel`.
struct CancelOrderRequest: Codable, Sendable {
    let motivo: String?
}

/// Una entrada del historial de estados de un pedido.
struct OrderStatusHistoryEntry: Codable, Identifiable, Sendable {
    let id: Int
    let orderId: Int
    let status: OrderStatus
    let changedBy: Int?
    let notas: String?
    let creadoEn: Date?
}
