import SwiftUI

/// Seguimiento de un pedido activo: línea de estados, estado del pago y código de confirmación.
/// Mientras el pedido espera pago permite pagarlo o cancelarlo.
struct OrderTrackingView: View {
    @State var viewModel: OrderTrackingViewModel
    @Environment(\.openURL) private var openURL
    @State private var showCancelConfirm = false

    private static let steps: [OrderStatus] = [.pendiente, .preparando, .listoParaRecoger, .enCamino, .entregado]

    var body: some View {
        Group {
            if let order = viewModel.order {
                ScrollView {
                    VStack(spacing: NMSpacing.s6) {
                        if order.status == .cancelado {
                            cancelledState(order)
                        } else {
                            timeline(order)
                        }

                        if order.status == .pendiente {
                            paymentSection(order)
                        }

                        if let codigo = order.codigoConfirmacion, order.status != .cancelado {
                            confirmationCode(codigo)
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
        .navigationTitle("Seguimiento")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("¿Cancelar este pedido?", isPresented: $showCancelConfirm, titleVisibility: .visible) {
            Button("Cancelar pedido", role: .destructive) {
                Task { await viewModel.cancel() }
            }
            Button("Volver", role: .cancel) {}
        } message: {
            Text("Se liberan los productos reservados. Esta acción no se puede deshacer.")
        }
        .onAppear { viewModel.startTracking() }
        .onDisappear { viewModel.stopTracking() }
    }

    private func timeline(_ order: Order) -> some View {
        let currentIndex = Self.steps.firstIndex(of: order.status) ?? 0
        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(Self.steps.enumerated()), id: \.offset) { index, step in
                timelineRow(step: step, isReached: index <= currentIndex, isLast: index == Self.steps.count - 1)
            }
        }
    }

    private func timelineRow(step: OrderStatus, isReached: Bool, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: NMSpacing.s3) {
            VStack(spacing: 0) {
                Image(nmIcon: isReached ? NMIcon.checkmarkCircleFilled : NMIcon.circleEmpty)
                    .foregroundColor(isReached ? NMColors.accent : NMColors.line)
                if !isLast {
                    Rectangle()
                        .fill(isReached ? NMColors.accent : NMColors.line)
                        .frame(width: 2)
                        .frame(minHeight: 32)
                }
            }
            Text(step.label)
                .nmStyle(isReached ? .bodyStrong : .body)
                .padding(.top, 1)
            Spacer()
        }
    }

    @ViewBuilder
    private func paymentSection(_ order: Order) -> some View {
        VStack(alignment: .leading, spacing: NMSpacing.s3) {
            HStack(spacing: NMSpacing.s2) {
                Image(nmIcon: NMIcon.creditCard).foregroundColor(NMColors.neutral)
                Text(paymentStatusText).nmStyle(.bodyStrong)
                Spacer()
                Text(NMFormat.currency(order.chargedTotal)).nmStyle(.price)
            }

            if let actionError = viewModel.actionError {
                HStack(alignment: .top, spacing: NMSpacing.s2) {
                    Image(nmIcon: NMIcon.alertCircle).foregroundColor(NMColors.error)
                    Text(actionError).nmStyle(.body, color: NMColors.error)
                }
            }

            if viewModel.awaitingPayment {
                NMButton(label: "Pagar con MercadoPago", variant: .primary, loading: viewModel.isPaying, fullWidth: true) {
                    Task {
                        if let url = await viewModel.pay() {
                            openURL(url)
                        }
                    }
                }
                NMButton(label: "Cancelar pedido", variant: .outline, loading: viewModel.isCancelling, fullWidth: true) {
                    showCancelConfirm = true
                }
            }
        }
        .padding(NMSpacing.s4)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
    }

    private var paymentStatusText: String {
        viewModel.payment?.isApproved == true ? "Pago aprobado · esperando a la tienda" : "Pago pendiente"
    }

    private func cancelledState(_ order: Order) -> some View {
        VStack(spacing: NMSpacing.s3) {
            Image(nmIcon: NMIcon.closeCircle).font(.system(size: 32)).foregroundColor(NMColors.error)
            Text("Pedido cancelado").nmStyle(.h3)
            if let motivo = order.motivoCancelacion, !motivo.isEmpty {
                Text(motivo).nmStyle(.body)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func confirmationCode(_ codigo: String) -> some View {
        VStack(spacing: NMSpacing.s1) {
            Text("Código de confirmación").nmStyle(.label)
            Text(codigo)
                .font(NMFont.numeric(24))
                .foregroundColor(NMColors.ink)
        }
        .frame(maxWidth: .infinity)
        .padding(NMSpacing.s4)
        .background(NMColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
        .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
    }
}
