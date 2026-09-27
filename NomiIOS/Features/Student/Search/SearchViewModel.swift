import Observation

/// Estado de la búsqueda. El texto se busca con 350 ms de espera tras la última pulsación; el
/// cambio de categoría busca de inmediato.
///
/// Limitación conocida: la búsqueda por categoría no cancela una búsqueda de texto pendiente,
/// así que una respuesta antigua puede llegar después de una nueva.
@MainActor
@Observable
final class SearchViewModel {
    var query: String = "" {
        didSet { scheduleSearch() }
    }
    var selectedCategory: String? {
        didSet { Task { await search() } }
    }

    private(set) var results: [Product] = []
    private(set) var isLoading = false
    private(set) var hasSearched = false
    private(set) var errorMessage: String?

    private let productsAPI: ProductsAPI
    private var searchTask: Task<Void, Never>?

    init(productsAPI: ProductsAPI) {
        self.productsAPI = productsAPI
    }

    private func scheduleSearch() {
        searchTask?.cancel()
        let task = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }
            await search()
        }
        searchTask = task
    }

    /// Sin texto ni categoría vuelve al estado inicial sin llamar al backend.
    func search() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty || selectedCategory != nil else {
            results = []
            hasSearched = false
            errorMessage = nil
            return
        }
        isLoading = true
        defer { isLoading = false }
        hasSearched = true
        do {
            let page = try await productsAPI.search(.init(
                nombre: query.trimmingCharacters(in: .whitespaces).isEmpty ? nil : query,
                categoria: selectedCategory,
                disponible: true,
                size: 30
            ))
            results = page.content
            errorMessage = nil
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? "No se pudo buscar."
        }
    }
}
