import Foundation

/// Producto recomendado. Nombre, precio y categoría vienen del catálogo real, no del modelo
/// de IA; `reason` es texto generado y ya saneado por el servicio de IA.
struct Recommendation: Codable, Identifiable, Sendable {
    var id: Int { productId }
    let productId: Int
    let nombre: String
    let precio: Decimal
    let categoria: String
    /// Relevancia entre 0 y 1.
    let score: Double
    let reason: String
}

/// Respuesta de `/ai/recommendations`.
struct RecommendationResponse: Codable, Sendable {
    let userId: Int
    let recommendations: [Recommendation]
    /// Proveedor que generó la lista, o `FALLBACK` si el servicio de IA no respondió.
    let generatedBy: String
}
