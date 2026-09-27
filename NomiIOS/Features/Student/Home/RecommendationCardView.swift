import SwiftUI

/// Tarjeta de recomendación. Ancho fijo en el carrusel de inicio; `width: nil` para ocupar la
/// columna en la cuadrícula de recomendaciones.
struct RecommendationCardView: View {
    let recommendation: Recommendation
    var width: CGFloat? = 140
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: NMSpacing.s1) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: NMRadius.lg)
                        .fill(NMColors.paperRaised)
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            Image(nmIcon: NMIcon.imagePlaceholder)
                                .font(.system(size: 22))
                                .foregroundColor(NMColors.neutral)
                        )

                    HStack(spacing: 3) {
                        Image(nmIcon: NMIcon.starFilled).font(.system(size: 9))
                        // Puntuación de 0 a 10 derivada de `score` (0 a 1).
                        Text("\(Int(recommendation.score * 10))")
                            .font(NMFont.semibold(11))
                    }
                    .foregroundColor(NMColors.ink)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(NMColors.surface.opacity(0.92))
                    .clipShape(Capsule())
                    .padding(6)
                }

                Text(recommendation.nombre)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(NMColors.ink)
                    .lineLimit(1)
                Text(recommendation.reason)
                    .nmStyle(.body)
                    .lineLimit(2)
                Text(NMFormat.currency(recommendation.precio)).nmStyle(.price)
            }
            .frame(width: width, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}
