import SwiftUI

/// Detalle de un pedido terminado: estado, código, productos y desglose de importes.
struct OrderDetailView: View {
    @State var viewModel: OrderDetailViewModel

    var body: some View {
        Group {
            if let order = viewModel.order {
                ScrollView {
                    VStack(alignment: .leading, spacing: NMSpacing.s5) {
                        header(order)
                        itemsCard(order)
                        if let notas = order.notas, !notas.isEmpty {
                            notesCard(notas)
                        }
                    }
                    .padding(NMSpacing.s5)
                }
                .background(NMColors.paper)
            } else if viewModel.isLoading {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity).background(NMColors.paper)
            } else {
                Text(viewModel.errorMessage ?? "No se pudo cargar el pedido.")
                    .nmStyle(.body, color: NMColors.error)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(NMColors.paper)
            }
        }
        .navigationTitle("Pedido #\(viewModel.orderId)")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    private func header(_ order: Order) -> some View {
        HStack {
            Text(order.status.label)
                .font(NMFont.semibold(14))
                .foregroundColor(order.status.color)
            Spacer()
            if let codigo = order.codigoConfirmacion {
                Text("Código: \(codigo)").nmStyle(.label)
            }
        }
        .padding(NMSpacing.s3)
        .background(order.status.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
    }

    private func itemsCard(_ order: Order) -> some View {
        VStack(spacing: NMSpacing.s2) {
            ForEach(order.items) { item in
                NMSummaryRow(label: "\(item.cantidad)× \(item.productNombre)", value: NMFormat.currency(item.subtotal))
            }
            NMDivider()
            NMSummaryRow(label: "Subtotal", value: NMFormat.currency(order.total))
            if let tarifa = order.tarifaServicio {
                NMSummaryRow(label: "Tarifa de servicio", value: NMFormat.currency(tarifa))
            }
            if let comision = order.comisionNomi {
                NMSummaryRow(label: "Comisión Nomi", value: NMFormat.currency(comision))
            }
            if let propina = order.propina, propina > 0 {
                NMSummaryRow(label: "Propina", value: NMFormat.currency(propina))
            }
            NMDivider()
            NMSummaryRow(label: "Total", value: NMFormat.currency(order.chargedTotal), bold: true)
        }
        .padding(NMSpacing.s4)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
    }

    private func notesCard(_ notas: String) -> some View {
        VStack(alignment: .leading, spacing: NMSpacing.s1) {
            Text("Notas").nmStyle(.label)
            Text(notas).nmStyle(.body)
        }
    }
}
