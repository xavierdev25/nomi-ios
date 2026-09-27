import SwiftUI

/// Todas las recomendaciones de la IA, en cuadrícula.
struct RecommendationsView: View {
    @State var viewModel: RecommendationsViewModel
    @Binding var path: NavigationPath

    private let columns = [GridItem(.flexible(), spacing: NMSpacing.s3), GridItem(.flexible(), spacing: NMSpacing.s3)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s2) {
                HStack(spacing: NMSpacing.s2) {
                    Image(nmIcon: NMIcon.sparkles).foregroundColor(NMColors.accent)
                    Text("Para ti").nmStyle(.h1)
                }
                Text("Elegidas por IA según tus preferencias y pedidos anteriores").nmStyle(.body)
            }
            .padding(.horizontal, NMSpacing.s5)
            .padding(.top, NMSpacing.s6)
            .padding(.bottom, NMSpacing.s5)

            if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity).padding(.top, NMSpacing.s8)
            } else if let error = viewModel.errorMessage {
                Text(error).nmStyle(.body, color: NMColors.error).padding(.horizontal, NMSpacing.s5)
            } else if viewModel.recommendations.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: NMSpacing.s3) {
                    ForEach(viewModel.recommendations) { recommendation in
                        RecommendationCardView(recommendation: recommendation, width: nil) {
                            path.append(StudentRoute.productDetail(id: recommendation.productId))
                        }
                    }
                }
                .padding(.horizontal, NMSpacing.s5)
            }

            Color.clear.frame(height: NMSpacing.s16)
        }
        .background(NMColors.paper)
        .navigationTitle("Recomendaciones")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.sparkles).font(.system(size: 28)).foregroundColor(NMColors.neutral)
            Text("Todavía no tenemos recomendaciones para ti").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }
}
