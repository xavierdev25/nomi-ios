import SwiftUI

/// Carrito: cantidades, propina para el repartidor y resumen de importes.
struct CartView: View {
    @Environment(CartStore.self) private var cartStore
    @Binding var path: NavigationPath

    /// Montos de propina ofrecidos; los que superan `CartStore.maxPropina` aparecen deshabilitados.
    private let tipOptions: [Decimal] = [0, 1, 2, 3, 5]

    var body: some View {
        Group {
            if cartStore.items.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: NMSpacing.s5) {
                        itemsList
                        tipPicker
                        summary
                    }
                    .padding(NMSpacing.s5)
                }
                .background(NMColors.paper)
                .safeAreaInset(edge: .bottom) { checkoutBar }
            }
        }
        .navigationTitle("Carrito")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var itemsList: some View {
        VStack(spacing: NMSpacing.s3) {
            ForEach(cartStore.items) { item in
                cartRow(item)
            }
        }
    }

    private func cartRow(_ item: CartItem) -> some View {
        HStack(spacing: NMSpacing.s3) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.product.nombre).nmStyle(.bodyStrong)
                Text(NMFormat.currency(item.product.precio)).nmStyle(.label)
            }
            Spacer()
            HStack(spacing: NMSpacing.s3) {
                Button {
                    cartStore.updateQuantity(productId: item.product.id, cantidad: item.cantidad - 1)
                } label: {
                    Image(nmIcon: item.cantidad <= 1 ? NMIcon.trash : NMIcon.minus)
                }
                Text("\(item.cantidad)")
                    .font(NMFont.numeric(15))
                    .frame(minWidth: 20)
                Button {
                    cartStore.updateQuantity(productId: item.product.id, cantidad: item.cantidad + 1)
                } label: {
                    Image(nmIcon: NMIcon.plus)
                }
            }
            .foregroundColor(NMColors.accent)
        }
        .padding(NMSpacing.s3)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
    }

    private var tipPicker: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s2) {
            Text("Propina para tu repartidor").nmStyle(.bodyStrong)
            // Desplazamiento horizontal: cinco chips no caben en un iPhone y un `HStack` partía
            // "Sin propina" en tres líneas.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NMSpacing.s2) {
                    ForEach(tipOptions, id: \.self) { amount in
                        let allowed = cartStore.canTip(amount)
                        NMTag(
                            label: amount == 0 ? "Sin propina" : NMFormat.currency(amount),
                            selected: cartStore.propina == amount,
                            action: allowed ? { cartStore.setPropina(amount) } : nil
                        )
                        .opacity(allowed ? 1 : 0.4)
                    }
                }
            }
            Text("Máximo \(NMFormat.currency(cartStore.maxPropina)) (50% del subtotal)").nmStyle(.label)
        }
    }

    private var summary: some View {
        VStack(spacing: NMSpacing.s2) {
            NMSummaryRow(label: "Subtotal", value: NMFormat.currency(cartStore.subtotal))
            NMSummaryRow(label: "Tarifa de servicio", value: NMFormat.currency(NMConstants.tarifaServicio))
            NMSummaryRow(label: "Comisión Nomi", value: NMFormat.currency(NMConstants.comisionNomi))
            if cartStore.propina > 0 {
                NMSummaryRow(label: "Propina", value: NMFormat.currency(cartStore.propina))
            }
            NMDivider()
            NMSummaryRow(label: "Total", value: NMFormat.currency(total), bold: true)
        }
    }

    private var total: Decimal {
        cartStore.subtotal + NMConstants.tarifaServicio + NMConstants.comisionNomi + cartStore.propina
    }

    private var checkoutBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total").nmStyle(.label)
                Text(NMFormat.currency(total)).nmStyle(.price)
            }
            Spacer()
            NMButton(label: "Continuar", variant: .primary, rightIcon: Image(nmIcon: NMIcon.arrowRight)) {
                path.append(StudentRoute.checkout)
            }
        }
        .padding(NMSpacing.s5)
        .background(NMColors.surface)
        .overlay(alignment: .top) { NMDivider() }
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s3) {
            Image(nmIcon: NMIcon.cart).font(.system(size: 32)).foregroundColor(NMColors.neutral)
            Text("Tu carrito está vacío").nmStyle(.h3)
            Text("Agrega productos desde el inicio o la búsqueda").nmStyle(.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NMColors.paper)
    }
}
