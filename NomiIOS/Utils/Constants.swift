import SwiftUI

/// Cargos fijos del pedido. Deben coincidir con `TARIFA_SERVICIO`, `COMISION_NOMI` y
/// `MAX_PROPINA_RATIO_PERCENT` de `CreateOrderHandler` en el backend: el servidor calcula el
/// monto real, pero el resumen previo al pago se calcula con estos valores.
enum NMConstants {
    static let tarifaServicio: Decimal = 0.50
    static let comisionNomi: Decimal = 0.20
    static let maxTipRatio: Decimal = 0.5
}

/// Presentación de cada estado del pedido.
extension OrderStatus {
    var label: String {
        switch self {
        case .pendiente: "Pendiente"
        case .preparando: "En preparación"
        case .listoParaRecoger: "Listo para recoger"
        case .enCamino: "En camino"
        case .entregado: "Entregado"
        case .cancelado: "Cancelado"
        }
    }

    var color: Color {
        switch self {
        case .pendiente: NMColors.warning
        case .preparando: NMColors.info
        case .listoParaRecoger: NMColors.infoStrong
        case .enCamino: NMColors.accent
        case .entregado: NMColors.success
        case .cancelado: NMColors.error
        }
    }
}
