import SwiftUI

/// Pestaña de inicio: saludo, recomendaciones de la IA y productos disponibles.
struct HomeView: View {
    @Environment(AuthStore.self) private var authStore
    @State var viewModel: HomeViewModel
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header

                if viewModel.isLoadingRecommendations || !viewModel.recommendations.isEmpty {
                    recommendationsSection
                }

                productsSection

                Color.clear.frame(height: NMSpacing.s16)
            }
        }
        .background(NMColors.paper)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadInitial()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: NMSpacing.s1) {
                Text("Hola, \(authStore.user?.nombres ?? "")")
                    .nmStyle(.h1)
                Text("¿Qué se te antoja hoy?")
                    .nmStyle(.body)
            }
            Spacer()
            HStack(spacing: NMSpacing.s2) {
                NMCartHeaderButton(variant: .subtle) {
                    path.append(StudentRoute.cart)
                }
                NMAvatar(name: fullName, size: 40)
            }
        }
        .padding(.horizontal, NMSpacing.s5)
        .padding(.top, NMSpacing.s6)
        .padding(.bottom, NMSpacing.s6)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Solo se muestra mientras carga o si hay recomendaciones: sin IA disponible la sección desaparece.
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            HStack(spacing: NMSpacing.s2) {
                Image(nmIcon: NMIcon.sparkles)
                    .foregroundColor(NMColors.accent)
                Text("Para ti").nmStyle(.h3)
                Spacer()
                Button("Ver todas") {
                    path.append(StudentRoute.recommendations)
                }
                .font(NMFont.semibold(13))
                .foregroundColor(NMColors.accent)
            }
            .padding(.horizontal, NMSpacing.s5)

            if viewModel.isLoadingRecommendations && viewModel.recommendations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, NMSpacing.s5)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: NMSpacing.s3) {
                        ForEach(viewModel.recommendations) { recommendation in
                            RecommendationCardView(recommendation: recommendation) {
                                path.append(StudentRoute.productDetail(id: recommendation.productId))
                            }
                        }
                    }
                    .padding(.horizontal, NMSpacing.s5)
                }
            }
        }
        .padding(.top, NMSpacing.s5)
    }

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            Text("Disponible ahora").nmStyle(.h3).padding(.horizontal, NMSpacing.s5)

            // El indicador solo sustituye a la lista en la primera carga; al recargar la lista sigue visible.
            if viewModel.isLoadingProducts && viewModel.products.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(NMSpacing.s8)
            } else if let errorMessage = viewModel.errorMessage, viewModel.products.isEmpty {
                Text(errorMessage)
                    .nmStyle(.body, color: NMColors.error)
                    .padding(.horizontal, NMSpacing.s5)
            } else if viewModel.products.isEmpty {
                emptyProductsState
            } else {
                LazyVStack(spacing: NMSpacing.s3) {
                    ForEach(viewModel.products) { product in
                        NMProductCard(product: product, variant: .list, showDescription: true) {
                            path.append(StudentRoute.productDetail(id: product.id))
                        }
                    }
                }
                .padding(.horizontal, NMSpacing.s5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, NMSpacing.s5)
    }

    private var emptyProductsState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.storefront)
                .font(.system(size: 28))
                .foregroundColor(NMColors.neutral)
            Text("Todavía no hay productos disponibles").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, NMSpacing.s8)
    }

    private var fullName: String {
        guard let user = authStore.user else { return "" }
        return [user.nombres, user.apellidos].compactMap { $0 }.joined(separator: " ")
    }
}
