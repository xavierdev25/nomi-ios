import SwiftUI

/// Productos favoritos. Se quitan con pulsación larga.
struct FavoriteProductsView: View {
    @State var viewModel: FavoriteProductsViewModel
    @Binding var path: NavigationPath

    private let columns = [GridItem(.flexible(), spacing: NMSpacing.s3), GridItem(.flexible(), spacing: NMSpacing.s3)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, NMSpacing.s8)
                } else if let error = viewModel.errorMessage {
                    Text(error).nmStyle(.body, color: NMColors.error).padding(.horizontal, NMSpacing.s5)
                } else if viewModel.products.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: NMSpacing.s3) {
                        ForEach(viewModel.products) { product in
                            NMProductCard(product: product, variant: .grid, showFavoriteIcon: true) {
                                path.append(StudentRoute.productDetail(id: product.id))
                            }
                            .contextMenu {
                                Button("Quitar de favoritos", role: .destructive) {
                                    Task { await viewModel.remove(product) }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, NMSpacing.s5)
                }
                Color.clear.frame(height: NMSpacing.s16)
            }
            .padding(.top, NMSpacing.s6)
        }
        .background(NMColors.paper)
        .navigationTitle("Productos favoritos")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.heart).font(.system(size: 28)).foregroundColor(NMColors.neutral)
            Text("Todavía no tienes productos favoritos").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }
}
