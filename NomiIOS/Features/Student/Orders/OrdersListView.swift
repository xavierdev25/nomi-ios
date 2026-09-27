import SwiftUI

/// Pestaña de pedidos, del más reciente al más antiguo, con el total realmente cobrado.
struct OrdersListView: View {
    @State var viewModel: OrdersListViewModel
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: NMSpacing.s5) {
                Text("Tus pedidos").nmStyle(.h1).padding(.horizontal, NMSpacing.s5)

                if viewModel.orders.isEmpty && viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity).padding(.top, NMSpacing.s8)
                } else if viewModel.orders.isEmpty, let error = viewModel.errorMessage {
                    Text(error).nmStyle(.body, color: NMColors.error).padding(.horizontal, NMSpacing.s5)
                } else if viewModel.orders.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: NMSpacing.s3) {
                        ForEach(viewModel.orders) { order in
                            orderRow(order)
                        }
                    }
                    .padding(.horizontal, NMSpacing.s5)
                }

                Color.clear.frame(height: NMSpacing.s16)
            }
            .padding(.top, NMSpacing.s6)
        }
        .background(NMColors.paper)
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.load() }
    }

    private func orderRow(_ order: Order) -> some View {
        Button {
            // Los pedidos terminados abren el detalle; los activos, el seguimiento (donde se paga o cancela).
            if order.status == .entregado || order.status == .cancelado {
                path.append(StudentRoute.orderDetail(id: order.id))
            } else {
                path.append(StudentRoute.orderTracking(id: order.id))
            }
        } label: {
            HStack(spacing: NMSpacing.s3) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pedido #\(order.id)").nmStyle(.bodyStrong)
                    Text("\(order.items.count) producto\(order.items.count == 1 ? "" : "s")").nmStyle(.label)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(NMFormat.currency(order.chargedTotal)).nmStyle(.price)
                    statusBadge(order.status)
                }
            }
            .padding(NMSpacing.s3)
            .background(NMColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: NMRadius.lg))
            .overlay(RoundedRectangle(cornerRadius: NMRadius.lg).stroke(NMColors.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func statusBadge(_ status: OrderStatus) -> some View {
        Text(status.label)
            .font(NMFont.semibold(11))
            .foregroundColor(status.color)
    }

    private var emptyState: some View {
        VStack(spacing: NMSpacing.s2) {
            Image(nmIcon: NMIcon.receiptOutline).font(.system(size: 28)).foregroundColor(NMColors.neutral)
            Text("Todavía no tienes pedidos").nmStyle(.body)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, NMSpacing.s8)
    }
}
