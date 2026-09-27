import SwiftUI

/// Confirmación del pedido y pago. Tras obtener la URL la abre en el navegador y reemplaza la
/// pila por el seguimiento del pedido.
struct CheckoutView: View {
    @State var viewModel: CheckoutViewModel
    @Environment(CartStore.self) private var cartStore
    @Environment(\.openURL) private var openURL
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                orderSummary
                aulaPicker
                meetingPointPicker
                notesField
            }
            .padding(NMSpacing.s5)
        }
        .background(NMColors.paper)
        .navigationTitle("Confirmar pedido")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) { payBar }
        .task { await viewModel.loadAulas() }
    }

    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s2) {
            Text("Resumen").nmStyle(.h3)
            VStack(spacing: NMSpacing.s2) {
                ForEach(cartStore.items) { item in
                    NMSummaryRow(label: "\(item.cantidad)× \(item.product.nombre)", value: NMFormat.currency(item.product.precio * Decimal(item.cantidad)))
                }
                NMDivider()
                NMSummaryRow(label: "Subtotal", value: NMFormat.currency(viewModel.subtotal))
                NMSummaryRow(label: "Tarifa de servicio", value: NMFormat.currency(NMConstants.tarifaServicio))
                NMSummaryRow(label: "Comisión Nomi", value: NMFormat.currency(NMConstants.comisionNomi))
                if cartStore.propina > 0 {
                    NMSummaryRow(label: "Propina", value: NMFormat.currency(cartStore.propina))
                }
                NMDivider()
                NMSummaryRow(label: "Total", value: NMFormat.currency(viewModel.total), bold: true)
            }
            .padding(NMSpacing.s4)
            .background(NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
        }
    }

    private var aulaPicker: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s2) {
            Text("¿A qué salón lo llevamos?").nmStyle(.h3)

            if viewModel.isLoadingAulas {
                ProgressView()
            } else if let error = viewModel.aulasError {
                Text(error).nmStyle(.body, color: NMColors.error)
            } else if viewModel.aulas.isEmpty {
                emptyAulasState
            } else {
                VStack(spacing: NMSpacing.s2) {
                    ForEach(viewModel.aulas) { aula in
                        aulaRow(aula)
                    }
                }
            }
        }
    }

    private func aulaRow(_ aula: Aula) -> some View {
        let isSelected = viewModel.selectedAulaId == aula.id
        return Button {
            viewModel.selectedAulaId = aula.id
        } label: {
            HStack(spacing: NMSpacing.s3) {
                Image(nmIcon: NMIcon.classroom).foregroundColor(isSelected ? NMColors.accent : NMColors.neutral)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: NMSpacing.s2) {
                        Text("\(aula.codigo) · \(aula.nombre)").nmStyle(.bodyStrong)
                        if aula.id == viewModel.lastUsedAulaId {
                            NMBadge(label: "Última usada", variant: .gray)
                        }
                    }
                    if let detail = aulaDetail(aula) {
                        Text(detail).nmStyle(.label)
                    }
                }
                Spacer()
                if isSelected {
                    Image(nmIcon: NMIcon.checkmarkCircleFilled).foregroundColor(NMColors.accent)
                }
            }
            .padding(NMSpacing.s3)
            .background(isSelected ? NMColors.accentSoft : NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(isSelected ? NMColors.accent : NMColors.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var emptyAulasState: some View {
        HStack(alignment: .top, spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.info).foregroundColor(NMColors.neutral)
            Text("No hay salones disponibles por el momento. Intenta de nuevo más tarde.")
                .nmStyle(.body)
        }
        .padding(NMSpacing.s3)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
    }

    private func aulaDetail(_ aula: Aula) -> String? {
        [aula.pabellon, aula.piso].compactMap { $0 }.joined(separator: " · ").isEmpty
            ? nil
            : [aula.pabellon, aula.piso].compactMap { $0 }.joined(separator: " · ")
    }

    private var meetingPointPicker: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s2) {
            Text("Punto de encuentro").nmStyle(.h3)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: NMSpacing.s2) {
                    ForEach(CheckoutViewModel.meetingPoints, id: \.value) { point in
                        NMTag(label: point.label, selected: viewModel.puntoEncuentro == point.value) {
                            viewModel.puntoEncuentro = point.value
                        }
                    }
                }
            }
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: NMSpacing.s2) {
            Text("Notas para el repartidor (opcional)").nmStyle(.h3)
            TextField("Ej: tocar la puerta suave, salón al fondo...", text: $viewModel.notas, axis: .vertical)
                .font(NMFont.regular(14))
                .lineLimit(3...5)
                .padding(NMSpacing.s3)
                .background(NMColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
                .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.alertCircle).foregroundColor(NMColors.error)
            Text(message).nmStyle(.body, color: NMColors.error)
        }
        .padding(NMSpacing.s3)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(NMColors.errorSoft)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.md))
    }

    private var payBar: some View {
        VStack(spacing: 0) {
            NMDivider()
            // Junto al botón que causó el error: al final del scroll quedaba fuera de la vista y parecía
            // que no pasaba nada.
            if case .failed(let message, _) = viewModel.phase {
                errorBanner(message)
                    .padding(.horizontal, NMSpacing.s5)
                    .padding(.top, NMSpacing.s4)
            }
            if case .failed(_, let orderId) = viewModel.phase, orderId != nil {
                NMButton(label: "Reintentar pago", variant: .primary, loading: viewModel.isProcessing, fullWidth: true) {
                    Task { await handlePaymentResult(await viewModel.retryPayment()) }
                }
                .padding(NMSpacing.s5)
            } else {
                NMButton(
                    label: "Pagar con MercadoPago · \(NMFormat.currency(viewModel.total))",
                    variant: .primary,
                    loading: viewModel.isProcessing,
                    disabled: !viewModel.canPay,
                    fullWidth: true
                ) {
                    Task { await handlePaymentResult(await viewModel.pay()) }
                }
                .padding(NMSpacing.s5)
            }
        }
        .background(NMColors.surface)
    }

    private func handlePaymentResult(_ url: URL?) async {
        if let url {
            openURL(url)
        }
        if let orderId = viewModel.completedOrderId {
            // Reemplaza Carrito → Checkout: el carrito ya está vacío y "Atrás" volvía a un checkout sin
            // nada que pagar.
            path = NavigationPath([StudentRoute.orderTracking(id: orderId)])
        }
    }
}
