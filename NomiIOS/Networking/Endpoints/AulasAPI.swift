import Foundation

/// Salones del campus a los que se puede entregar un pedido.
struct AulasAPI: Sendable {
    let client: APIClient

    /// Solo los salones activos: los únicos válidos para un pedido nuevo.
    func activas() async throws -> [Aula] {
        try await client.send(APIEndpoint(path: "aulas/activas", method: .get))
    }
}
