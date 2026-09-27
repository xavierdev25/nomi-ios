import SwiftUI

/// `filled`: círculo de color de acción. `subtle`: superficie con borde (opción por defecto).
enum NMCartButtonVariant {
    case filled, subtle
}

/// Botón del carrito con contador de unidades. Lee `CartStore` del entorno.
struct NMCartHeaderButton: View {
    @Environment(CartStore.self) private var cartStore
    var variant: NMCartButtonVariant = .subtle
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .fill(variant == .filled ? NMColors.accent : NMColors.surface)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle().stroke(NMColors.line, lineWidth: variant == .filled ? 0 : 1)
                    )
                    .nmShadow(.whisper)
                    .overlay {
                        Image(nmIcon: NMIcon.cart)
                            .foregroundColor(variant == .filled ? NMColors.onAccent : NMColors.accent)
                    }

                if cartStore.itemCount > 0 {
                    Text("\(cartStore.itemCount)")
                        .font(NMFont.semibold(11))
                        .foregroundColor(NMColors.onAccent)
                        .frame(minWidth: 20, minHeight: 20)
                        .background(variant == .filled ? NMColors.ink : NMColors.accent)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(NMColors.surface, lineWidth: 2))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
