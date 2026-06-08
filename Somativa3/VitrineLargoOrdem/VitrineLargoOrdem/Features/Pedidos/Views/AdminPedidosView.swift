import SwiftUI

/// Painel administrativo de pedidos — exibido apenas para usuários
/// com role `admin`. Permite filtrar, buscar, avançar status e
/// cancelar qualquer pedido do sistema.
struct AdminPedidosView: View {
    @ObservedObject var viewModel: AdminPedidosViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.md) {
                    resumo
                    chipsFiltro
                    listaPedidos
                }
                .padding(DSSpacing.md)
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Admin · Pedidos")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.termoBusca,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Buscar por número")
            .onAppear { viewModel.recarregar() }
            .refreshable { viewModel.recarregar() }
        }
    }

    // MARK: - Resumo do painel

    private var resumo: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total de pedidos").font(DSFont.metadata).foregroundStyle(DSColor.textSecondary)
                    Text("\(viewModel.totalPedidos)")
                        .font(DSFont.screenTitle)
                        .accessibilityLabel("\(viewModel.totalPedidos) pedidos no total")
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Faturamento").font(DSFont.metadata).foregroundStyle(DSColor.textSecondary)
                    Text(viewModel.totalFaturamentoFormatado)
                        .font(DSFont.sectionTitle)
                        .foregroundStyle(DSColor.primary)
                        .accessibilityLabel("Faturamento total \(PrecoFormatter.acessivel(viewModel.totalFaturamento))")
                }
            }
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    // MARK: - Chips de filtro

    private var chipsFiltro: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                chip(rotulo: "Todos",
                     simbolo: "tray.full.fill",
                     total: viewModel.totalPedidos,
                     ativo: viewModel.filtroStatus == nil) {
                    viewModel.filtroStatus = nil
                }

                ForEach(viewModel.contagemPorStatus, id: \.status) { item in
                    chip(rotulo: item.status.titulo,
                         simbolo: item.status.simbolo,
                         total: item.total,
                         ativo: viewModel.filtroStatus == item.status) {
                        viewModel.filtroStatus = item.status
                    }
                }
            }
            .padding(.horizontal, DSSpacing.xxs)
        }
    }

    private func chip(rotulo: String, simbolo: String, total: Int, ativo: Bool, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: simbolo).font(.caption.weight(.semibold)).accessibilityHidden(true)
                Text(rotulo).font(DSFont.metadata.weight(.medium))
                Text("\(total)")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 1)
                    .background(ativo ? Color.white.opacity(0.25) : DSColor.primary.opacity(0.15))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .frame(minHeight: DSSpacing.touchTargetMin)
            .background(ativo ? DSColor.primary : DSColor.surface)
            .foregroundStyle(ativo ? DSColor.textOnAccent : DSColor.textPrimary)
            .clipShape(Capsule())
            .overlay {
                Capsule().strokeBorder(DSColor.border, lineWidth: ativo ? 0 : 1)
            }
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(ativo ? "\(rotulo), selecionado, \(total) pedidos" : "\(rotulo), \(total) pedidos")
    }

    // MARK: - Lista

    @ViewBuilder
    private var listaPedidos: some View {
        if viewModel.pedidosFiltrados.isEmpty {
            ContentUnavailableView {
                Label("Sem pedidos", systemImage: "tray")
            } description: {
                Text("Não há pedidos para os filtros selecionados.")
            }
            .padding(.top, DSSpacing.xl)
        } else {
            VStack(spacing: DSSpacing.sm) {
                ForEach(viewModel.pedidosFiltrados) { pedido in
                    NavigationLink {
                        AdminDetalhePedidoView(pedido: pedido, viewModel: viewModel)
                    } label: {
                        cartao(pedido)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func cartao(_ pedido: Pedido) -> some View {
        let dono = viewModel.donoDoPedido(pedido)
        return VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pedido.numero).font(DSFont.cardTitle)
                    Text(pedido.criadoEm.formatted(date: .abbreviated, time: .shortened))
                        .font(DSFont.metadata)
                        .foregroundStyle(DSColor.textSecondary)
                }
                Spacer()
                badge(pedido.status)
            }
            HStack {
                Image(systemName: "person.fill")
                    .foregroundStyle(DSColor.textSecondary)
                    .accessibilityHidden(true)
                Text(dono?.nome ?? "Usuário removido").font(DSFont.body)
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
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg).strokeBorder(DSColor.border, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Pedido \(pedido.numero) de \(dono?.nome ?? "desconhecido"), status \(pedido.status.titulo), total \(pedido.totalAcessivel).")
    }

    @ViewBuilder
    private func badge(_ status: StatusPedido) -> some View {
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
