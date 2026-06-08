import SwiftUI

struct PedidosView: View {
    @ObservedObject var viewModel: PedidosViewModel
    let dependencies: AppDependencies

    var body: some View {
        Group {
            if viewModel.estaVazio {
                estadoVazio
            } else {
                lista
            }
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Meus pedidos")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { viewModel.recarregar() }
    }

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Você ainda não fez pedidos", systemImage: "bag")
        } description: {
            Text("Quando finalizar uma compra, ela aparece aqui com timeline em tempo real.")
        }
    }

    private var lista: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(viewModel.pedidos) { pedido in
                    NavigationLink {
                        DetalhePedidoView(
                            pedido: pedido,
                            viewModel: viewModel
                        )
                    } label: {
                        cartaoResumo(pedido)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.md)
        }
    }

    private func cartaoResumo(_ pedido: Pedido) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pedido.numero)
                        .font(DSFont.cardTitle)
                        .foregroundStyle(DSColor.textPrimary)
                    Text(pedido.criadoEm.formatted(date: .abbreviated, time: .shortened))
                        .font(DSFont.metadata)
                        .foregroundStyle(DSColor.textSecondary)
                }
                Spacer()
                badgeStatus(pedido.status)
            }
            HStack {
                Text("\(pedido.quantidadeTotal) \(pedido.quantidadeTotal == 1 ? "item" : "itens")")
                    .font(DSFont.body)
                Spacer()
                Text(pedido.totalFormatado)
                    .font(DSFont.preco)
                    .foregroundStyle(DSColor.primary)
                    .accessibilityLabel(pedido.totalAcessivel)
            }
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
        .overlay {
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pedido \(pedido.numero), status \(pedido.status.titulo), total \(pedido.totalAcessivel), com \(pedido.quantidadeTotal) itens.")
        .accessibilityHint("Toque duplo para abrir os detalhes.")
    }

    @ViewBuilder
    private func badgeStatus(_ status: StatusPedido) -> some View {
        let (cor, fundo): (Color, Color) = {
            switch status {
            case .recebido: return (.blue, .blue.opacity(0.15))
            case .emProducao: return (.orange, .orange.opacity(0.15))
            case .despachado: return (.purple, .purple.opacity(0.15))
            case .entregue: return (.green, .green.opacity(0.15))
            case .cancelado: return (.red, .red.opacity(0.15))
            }
        }()
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: status.simbolo)
                .accessibilityHidden(true)
            Text(status.titulo)
        }
        .font(DSFont.metadata.weight(.semibold))
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xxs)
        .background(fundo)
        .foregroundStyle(cor)
        .clipShape(Capsule())
    }
}
