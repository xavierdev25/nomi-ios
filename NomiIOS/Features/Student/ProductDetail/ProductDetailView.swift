import SwiftUI

/// Detalle de producto: imagen, precio, descripción, favorito, acceso a la tienda y selector
/// de cantidad para agregar al carrito.
struct ProductDetailView: View {
    @State var viewModel: ProductDetailViewModel
    @Environment(CartStore.self) private var cartStore
    @Binding var path: NavigationPath
    @State private var quantity = 1
    @State private var showStoreConflictAlert = false

    var body: some View {
        Group {
            if let product = viewModel.product {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        heroImage(product)
                        details(product)
                    }
                }
                .background(NMColors.paper)
                .safeAreaInset(edge: .bottom) { addToCartBar(product) }
            } else if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(NMColors.paper)
            } else {
                Text(viewModel.errorMessage ?? "No se pudo cargar el producto.")
                    .nmStyle(.body, color: NMColors.error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(NMColors.paper)
            }
        }
        .navigationTitle("Producto")
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
        .alert("Ya tienes productos de otra tienda", isPresented: $showStoreConflictAlert) {
            Button("Entendido", role: .cancel) {}
        } message: {
            Text("Vacía tu carrito antes de agregar productos de una tienda distinta.")
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder
    private func heroImage(_ product: Product) -> some View {
        Group {
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
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var imagePlaceholder: some View {
        ZStack {
            NMColors.paperRaised
            Image(nmIcon: NMIcon.imagePlaceholder).font(.system(size: 40)).foregroundColor(NMColors.neutral)
        }
    }

    private func details(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: NMSpacing.s4) {
            HStack {
                NMBadge(label: NMFormat.category(product.categoria), variant: .gray)
                if !product.disponible {
                    NMBadge(label: "Agotado", variant: .error)
                }
                Spacer()
            }

            Text(product.nombre).nmStyle(.h1)
            Text(NMFormat.currency(product.precio)).nmStyle(.price)

            if let descripcion = product.descripcion, !descripcion.isEmpty {
                Text(descripcion).nmStyle(.body)
            }

            NMDivider()

            Button {
                path.append(StudentRoute.storeDetail(id: product.storeId))
            } label: {
                HStack(spacing: NMSpacing.s2) {
                    Image(nmIcon: NMIcon.storefront)
                    Text("Ver tienda").font(NMFont.semibold(14))
                    Spacer()
                    Image(nmIcon: NMIcon.chevronForward)
                }
                .foregroundColor(NMColors.ink)
            }

            quantityStepper
        }
        .padding(NMSpacing.s5)
    }

    private var quantityStepper: some View {
        HStack(spacing: NMSpacing.s4) {
            Text("Cantidad").nmStyle(.bodyStrong)
            Spacer()
            HStack(spacing: NMSpacing.s4) {
                Button { if quantity > 1 { quantity -= 1 } } label: {
                    Image(nmIcon: NMIcon.minus)
                }
                .disabled(quantity <= 1)

                Text("\(quantity)")
                    .font(NMFont.numeric(16))
                    .frame(minWidth: 24)

                Button { quantity += 1 } label: {
                    Image(nmIcon: NMIcon.plus)
                }
            }
            .foregroundColor(NMColors.accent)
        }
    }

    private func addToCartBar(_ product: Product) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total").nmStyle(.label)
                Text(NMFormat.currency(product.precio * Decimal(quantity))).nmStyle(.price)
            }
            Spacer()
            NMButton(label: "Agregar al carrito", variant: .primary, disabled: !product.disponible) {
                // Un carrito solo admite productos de una tienda: si es de otra, se avisa en vez de agregarlo.
                let added = cartStore.addItem(product, cantidad: quantity)
                if added {
                    path.removeLast()
                } else {
                    showStoreConflictAlert = true
                }
            }
        }
        .padding(NMSpacing.s5)
        .background(NMColors.surface)
        .overlay(alignment: .top) { NMDivider() }
    }
}
