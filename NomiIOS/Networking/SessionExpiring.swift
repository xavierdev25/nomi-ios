/// Receptor del aviso "la sesión ya no es válida". Lo implementa `AuthStore` y lo recibe
/// `APIClient`, de modo que la capa de red no depende de la capa de estado.
protocol SessionExpiring: Sendable {
    func sessionDidExpire() async
}
