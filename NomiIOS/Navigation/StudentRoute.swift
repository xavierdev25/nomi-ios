import Foundation

/// Destinos que se apilan sobre la barra de pestañas del estudiante.
enum StudentRoute: Hashable {
    case productDetail(id: Int)
    case storeDetail(id: Int)
    case cart
    case checkout
    case orderDetail(id: Int)
    case orderTracking(id: Int)
    case recommendations
    case favoriteProducts
    case favoriteStores
}
