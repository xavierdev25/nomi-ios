import Foundation

/// Recomendaciones personalizadas (`/ai/recommendations`), que el backend obtiene del
/// servicio de IA. Si la IA no responde, el backend devuelve una lista vacía con
/// `generatedBy = "FALLBACK"` en lugar de un error.
struct AiAPI: Sendable {
    let client: APIClient

    /// - Parameter maxRecommendations: el backend acepta de 1 a 20. El nombre del parámetro de
    ///   query es exactamente `maxRecommendations`.
    func getRecommendations(maxRecommendations: Int = 5) async throws -> RecommendationResponse {
        let endpoint = APIEndpoint(
            path: "ai/recommendations",
            method: .get,
            query: ["maxRecommendations": String(maxRecommendations)]
        )
        return try await client.send(endpoint)
    }
}
