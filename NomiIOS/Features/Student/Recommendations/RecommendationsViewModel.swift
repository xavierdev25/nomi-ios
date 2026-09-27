import Observation

/// Pide hasta 20 recomendaciones, el máximo que acepta el backend.
@MainActor
@Observable
final class RecommendationsViewModel {
    private(set) var recommendations: [Recommendation] = []
    private(set) var isLoading = true
    private(set) var errorMessage: String?

    private let aiAPI: AiAPI

    init(aiAPI: AiAPI) {
        self.aiAPI = aiAPI
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await aiAPI.getRecommendations(maxRecommendations: 20)
            recommendations = response.recommendations
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudieron cargar las recomendaciones."
        }
    }
}
