import SwiftUI

/// Fila de tienda pulsable. El tiempo "15-25 min" es un valor fijo: el backend no calcula
/// tiempos de entrega.
struct NMStoreCard: View {
    let store: Store
    var showFavoriteIcon: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: NMSpacing.s3) {
                avatarView
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: NMSpacing.s1) {
                    Text(store.nombre)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(NMColors.ink)
                    if let descripcion = store.descripcion {
                        Text(descripcion).nmStyle(.body).lineLimit(2)
                    }
                    HStack(spacing: NMSpacing.s2) {
                        NMBadge(label: "15-25 min", variant: .gray)
                        HStack(spacing: 4) {
                            Circle()
                                .fill(store.activo ? NMColors.success : NMColors.error)
                                .frame(width: 6, height: 6)
                            // Refleja `activo` (tienda habilitada), no el horario de atención.
                            Text(store.activo ? "Abierto" : "Cerrado")
                                .nmStyle(.label, color: store.activo ? NMColors.success : NMColors.error)
                        }
                    }
                }

                Spacer()
                Image(nmIcon: showFavoriteIcon ? NMIcon.heart : NMIcon.chevronForward)
                    .foregroundColor(NMColors.neutral)
            }
            .padding(NMSpacing.s3)
            .background(NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .nmShadow(.whisper)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let urlString = store.imagenUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    placeholderIcon
                }
            }
        } else {
            placeholderIcon
        }
    }

    private var placeholderIcon: some View {
        ZStack {
            Circle().fill(NMColors.paperRaised)
            Image(nmIcon: NMIcon.storefront).foregroundColor(NMColors.neutral)
        }
    }
}
