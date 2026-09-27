import SwiftUI

/// `grid`: tarjeta vertical para cuadrículas. `list`: fila horizontal con descripción.
enum NMProductCardVariant {
    case grid, list
}

/// Tarjeta de producto pulsable. Muestra la categoría, o la disponibilidad si
/// `showAvailabilityBadge` es `true`.
struct NMProductCard: View {
    let product: Product
    var variant: NMProductCardVariant = .grid
    var showDescription: Bool = false
    var showAvailabilityBadge: Bool = false
    var showFavoriteIcon: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            switch variant {
            case .grid: gridBody
            case .list: listBody
            }
        }
        .buttonStyle(.plain)
    }

    private var gridBody: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s1) {
            imageView
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
                .overlay(alignment: .topTrailing) { favoriteOverlay }

            Text(product.nombre)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(NMColors.ink)
                .lineLimit(1)
            Text(NMFormat.currency(product.precio)).nmStyle(.price)
            badgeRow
        }
        .padding(NMSpacing.s2)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .nmShadow(.whisper)
    }

    private var listBody: some View {
        HStack(alignment: .top, spacing: NMSpacing.s3) {
            imageView
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))

            VStack(alignment: .leading, spacing: NMSpacing.s1) {
                Text(product.nombre)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(NMColors.ink)
                if showDescription, let descripcion = product.descripcion {
                    Text(descripcion).nmStyle(.body).lineLimit(2)
                }
                Spacer(minLength: NMSpacing.s1)
                HStack {
                    Text(NMFormat.currency(product.precio))
                        .font(NMFont.numeric(16))
                        .foregroundColor(NMColors.accent)
                    Spacer()
                    badgeRow
                }
            }
        }
        .padding(NMSpacing.s3)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .nmShadow(.whisper)
    }

    @ViewBuilder
    private var imageView: some View {
        if let urlString = product.imagenUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    imagePlaceholder
                }
            }
        } else {
            imagePlaceholder
        }
    }

    private var imagePlaceholder: some View {
        ZStack {
            Rectangle().fill(NMColors.paperRaised)
            Image(nmIcon: NMIcon.imagePlaceholder).foregroundColor(NMColors.neutral)
        }
    }

    private var badgeRow: some View {
        Group {
            if showAvailabilityBadge {
                NMBadge(label: product.disponible ? "Disponible" : "Agotado", variant: product.disponible ? .success : .error)
            } else {
                NMBadge(label: NMFormat.category(product.categoria), variant: .gray)
            }
        }
    }

    @ViewBuilder
    private var favoriteOverlay: some View {
        if showFavoriteIcon {
            Image(nmIcon: NMIcon.heart)
                .foregroundColor(.white)
                .padding(6)
                .background(.black.opacity(0.25))
                .clipShape(Circle())
                .padding(6)
        }
    }
}
