import SwiftUI

/// Búsqueda de productos por nombre y categoría, en cuadrícula de dos columnas.
struct SearchView: View {
    @State var viewModel: SearchViewModel
    @Binding var path: NavigationPath
    @FocusState private var fieldFocused: Bool

    private let categories: [(value: String, label: String)] = [
        ("COMIDA", "Comida"), ("BEBIDA", "Bebida"), ("SNACK", "Snack"), ("POSTRE", "Postre"), ("OTRO", "Otro"),
    ]

    private let columns = [GridItem(.flexible(), spacing: NMSpacing.s3), GridItem(.flexible(), spacing: NMSpacing.s3)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                Text("Buscar").nmStyle(.h1).padding(.horizontal, NMSpacing.s5)

                searchField
                    .padding(.horizontal, NMSpacing.s5)

                categoryChips

                content
                    .padding(.horizontal, NMSpacing.s5)

                Color.clear.frame(height: NMSpacing.s16)
            }
            .padding(.top, NMSpacing.s6)
        }
        .background(NMColors.paper)
        .scrollDismissesKeyboard(.interactively)
    }

    private var searchField: some View {
        HStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.searchOutline).foregroundColor(NMColors.neutral)
            TextField("Productos, tiendas...", text: $viewModel.query)
                .font(NMFont.medium(15))
                .foregroundColor(NMColors.ink)
                .focused($fieldFocused)
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(nmIcon: NMIcon.closeCircle).foregroundColor(NMColors.neutral)
                }
            }
        }
        .padding(.horizontal, NMSpacing.s4)
        .frame(height: 48)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: NMRadius.lg)
                .stroke(fieldFocused ? NMColors.accent : NMColors.line, lineWidth: fieldFocused ? 1.5 : 1)
        )
        .animation(NMEasing.inOut, value: fieldFocused)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: NMSpacing.s2) {
                NMTag(label: "Todas", selected: viewModel.selectedCategory == nil) {
                    viewModel.selectedCategory = nil
                }
                ForEach(categories, id: \.value) { category in
                    NMTag(label: category.label, selected: viewModel.selectedCategory == category.value) {
                        viewModel.selectedCategory = viewModel.selectedCategory == category.value ? nil : category.value
                    }
                }
            }
            .padding(.horizontal, NMSpacing.s5)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView().frame(maxWidth: .infinity).padding(.top, NMSpacing.s8)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage).nmStyle(.body, color: NMColors.error)
        } else if !viewModel.hasSearched {
            promptState
        } else if viewModel.results.isEmpty {
            emptyState
        } else {
            LazyVGrid(columns: columns, spacing: NMSpacing.s3) {
                ForEach(viewModel.results) { product in
                    NMProductCard(product: product, variant: .grid) {
                        path.append(StudentRoute.productDetail(id: product.id))
                    }
                }
            }
        }
    }

    private var promptState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.searchOutline).font(.system(size: 26)).foregroundColor(NMColors.neutral)
            Text("Busca productos por nombre o categoría").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.info).font(.system(size: 26)).foregroundColor(NMColors.neutral)
            Text("Sin resultados para tu búsqueda").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }
}
