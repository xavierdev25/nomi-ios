import SwiftUI

/// Detalle de tienda: datos, horario, favorito y menú de productos disponibles.
struct StoreDetailView: View {
    @State var viewModel: StoreDetailViewModel
    @Binding var path: NavigationPath

    var body: some View {
        Group {
            if let store = viewModel.store {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        header(store)
                        productsList
                    }
                }
                .background(NMColors.paper)
            } else if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(NMColors.paper)
            } else {
                Text(viewModel.errorMessage ?? "No se pudo cargar la tienda.")
                    .nmStyle(.body, color: NMColors.error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(NMColors.paper)
            }
        }
        .navigationTitle(viewModel.store?.nombre ?? "Tienda")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleFavorite() }
                } label: {
                    Image(nmIcon: viewModel.isFavorite ? NMIcon.heartFilled : NMIcon.heart)
                        .foregroundColor(viewModel.isFavorite ? NMColors.error : NMColors.ink)
                }
            }
        }
        .task { await viewModel.load() }
    }

    private func header(_ store: Store) -> some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            HStack(spacing: NMSpacing.s3) {
                storeAvatar(store)
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.nombre).nmStyle(.h2)
                    HStack(spacing: 4) {
                        Circle().fill(store.activo ? NMColors.success : NMColors.error).frame(width: 6, height: 6)
                        // Refleja `activo` (tienda habilitada), no el horario de atención.
                        Text(store.activo ? "Abierto" : "Cerrado")
                            .nmStyle(.label, color: store.activo ? NMColors.success : NMColors.error)
                    }
                }
            }
            if let descripcion = store.descripcion, !descripcion.isEmpty {
                Text(descripcion).nmStyle(.body)
            }
            if let horario = horarioText(store) {
                HStack(spacing: NMSpacing.s1) {
                    Image(nmIcon: NMIcon.clock).foregroundColor(NMColors.neutral)
                    Text(horario).nmStyle(.label)
                }
            }
        }
        .padding(NMSpacing.s5)
    }

    private func storeAvatar(_ store: Store) -> some View {
        Group {
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
        .frame(width: 64, height: 64)
        .clipShape(Circle())
    }

    private var placeholderIcon: some View {
        ZStack {
            Circle().fill(NMColors.paperRaised)
            Image(nmIcon: NMIcon.storefront).foregroundColor(NMColors.neutral)
        }
    }

    private func horarioText(_ store: Store) -> String? {
        guard let apertura = store.horarioApertura, let cierre = store.horarioCierre else { return nil }
        return "\(apertura) – \(cierre)"
    }

    @ViewBuilder
    private var productsList: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            Text("Menú").nmStyle(.h3).padding(.horizontal, NMSpacing.s5)

            if viewModel.products.isEmpty {
                Text("Esta tienda no tiene productos disponibles todavía.")
                    .nmStyle(.body)
                    .padding(.horizontal, NMSpacing.s5)
                    .padding(.vertical, NMSpacing.s6)
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
        .padding(.bottom, NMSpacing.s8)
    }
}
