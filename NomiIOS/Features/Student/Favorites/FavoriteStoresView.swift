import SwiftUI

/// Tiendas favoritas.
struct FavoriteStoresView: View {
    @State var viewModel: FavoriteStoresViewModel
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s3) {
                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, NMSpacing.s8)
                } else if let error = viewModel.errorMessage {
                    Text(error).nmStyle(.body, color: NMColors.error).padding(.horizontal, NMSpacing.s5)
                } else if viewModel.stores.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: NMSpacing.s3) {
                        ForEach(viewModel.stores) { store in
                            NMStoreCard(store: store, showFavoriteIcon: true) {
                                path.append(StudentRoute.storeDetail(id: store.id))
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
        .navigationTitle("Tiendas favoritas")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.storefront).font(.system(size: 28)).foregroundColor(NMColors.neutral)
            Text("Todavía no tienes tiendas favoritas").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }
}
