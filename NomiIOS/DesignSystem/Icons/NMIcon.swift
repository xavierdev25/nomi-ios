import SwiftUI

/// Nombres de SF Symbols usados en la app. Una sola librería de iconos para mantener un
/// trazo coherente.
enum NMIcon {
    static let homeFilled = "house.fill"
    static let homeOutline = "house"
    static let searchFilled = "magnifyingglass.circle.fill"
    static let searchOutline = "magnifyingglass"
    static let receiptFilled = "doc.text.fill"
    static let receiptOutline = "doc.text"
    static let personFilled = "person.fill"
    static let personOutline = "person"

    static let mail = "envelope"
    static let lock = "lock"
    static let eye = "eye"
    static let eyeSlash = "eye.slash"
    static let phone = "phone"
    static let arrowBack = "chevron.left"
    static let alertCircle = "exclamationmark.circle"
    static let sparkles = "sparkles"
    static let school = "graduationcap"

    static let storefront = "storefront"
    static let cart = "cart"
    static let cartFilled = "cart.fill"
    static let imagePlaceholder = "photo"
    static let heart = "heart"
    static let heartFilled = "heart.fill"
    static let chevronForward = "chevron.right"
    static let chevronDown = "chevron.down"
    static let star = "star"
    static let starFilled = "star.fill"
    static let clock = "clock"
    static let close = "xmark"
    static let closeCircle = "xmark.circle.fill"
    static let plus = "plus"
    static let minus = "minus"
    static let checkmark = "checkmark"
    static let checkmarkCircleFilled = "checkmark.circle.fill"
    static let trash = "trash"
    static let filter = "slider.horizontal.3"

    static let info = "info.circle"
    static let tag = "tag"

    static let classroom = "building.2"
    static let pin = "mappin.and.ellipse"
    static let note = "note.text"
    static let creditCard = "creditcard"
    static let bicycle = "bicycle"
    static let circleEmpty = "circle"
    static let arrowRight = "arrow.right"
    static let refresh = "arrow.clockwise"

    static let settings = "gearshape"
    static let logout = "rectangle.portrait.and.arrow.right"
    static let bell = "bell"
    static let help = "questionmark.circle"
    static let shield = "checkmark.shield"
}

/// `Image(nmIcon: NMIcon.cart)`.
extension Image {
    init(nmIcon name: String) {
        self.init(systemName: name)
    }
}
