import SwiftUI

/// Tela admin de detalhe — permite alterar status de qualquer pedido
/// para qualquer valor válido, com confirmação.
struct AdminDetalhePedidoView: View {
    let pedido: Pedido
    @ObservedObject var viewModel: AdminPedidosViewModel

    @State private var novoStatus: StatusPedido?
    @State private var mostrandoConfirmacaoCancelar = false

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                cabecalho
                cliente
                acaoStatus
                itens
                resumoFinanceiro
            }
            .padding(DSSpacing.md)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Pedido \(pedido.numero)")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancelar pedido?",
                            isPresented: $mostrandoConfirmacaoCancelar,
                            titleVisibility: .visible) {
            Button("Cancelar pedido", role: .destructive) {
                viewModel.cancelar(pedido)
            }
            Button("Manter pedido", role: .cancel) {}
        } message: {
            Text("Esta ação é definitiva. O cliente verá o status atualizado em \"Meus Pedidos\".")
        }
    }

    // MARK: - Cabeçalho

    private var cabecalho: some View {
        VStack(spacing: DSSpacing.xs) {
            Text(pedido.numero)
                .font(DSFont.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: DSSpacing.xs) {
                Image(systemName: pedido.status.simbolo)
                Text(pedido.status.titulo)
            }
            .font(DSFont.cardTitle)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
            .background(DSColor.primarySoft)
            .foregroundStyle(DSColor.primary)
            .clipShape(Capsule())

            Text("Criado em \(pedido.criadoEm.formatted(date: .abbreviated, time: .shortened))")
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Dados do cliente

    private var cliente: some View {
        let dono = viewModel.donoDoPedido(pedido)
        return VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("CLIENTE".uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(dono?.nome ?? "Usuário removido").font(DSFont.cardTitle)
                if let dono { Text(dono.email).font(DSFont.metadata).foregroundStyle(DSColor.textSecondary) }
            }
            Divider()
            Text("ENTREGA".uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)
            Text(pedido.enderecoLinha1).font(DSFont.body)
            Text(pedido.enderecoLinha2)
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    // MARK: - Ação: alterar status

    private var acaoStatus: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("ALTERAR STATUS".uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)

            ForEach(StatusPedido.allCases) { status in
                let selecionado = pedido.status == status
                Button {
                    if status == .cancelado {
                        mostrandoConfirmacaoCancelar = true
                    } else {
                        viewModel.definirStatus(status, para: pedido)
                    }
                } label: {
                    HStack {
                        Image(systemName: status.simbolo)
                            .frame(width: 24)
                            .foregroundStyle(corDoStatus(status))
                            .accessibilityHidden(true)
                        Text(status.titulo).font(DSFont.body)
                        Spacer()
                        if selecionado {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(DSColor.primary)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(DSSpacing.sm)
                    .frame(minHeight: DSSpacing.touchTargetMin)
                    .background(selecionado ? DSColor.primarySoft : DSColor.surface)
                    .foregroundStyle(DSColor.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd))
                    .overlay {
                        RoundedRectangle(cornerRadius: DSSpacing.cornerMd)
                            .strokeBorder(selecionado ? DSColor.primary : DSColor.border, lineWidth: selecionado ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
                .disabled(selecionado)
                .accessibilityLabel("Definir status como \(status.titulo)")
                .accessibilityAddTraits(selecionado ? [.isSelected, .isButton] : .isButton)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    private func corDoStatus(_ status: StatusPedido) -> Color {
        switch status {
        case .recebido: return .blue
        case .emProducao: return .orange
        case .despachado: return .purple
        case .entregue: return .green
        case .cancelado: return .red
        }
    }

    // MARK: - Itens

    private var itens: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("ITENS (\(pedido.quantidadeTotal))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)

            ForEach(pedido.itens) { item in
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: item.imagemNome)
                        .foregroundStyle(DSColor.primary)
                        .frame(width: 36, height: 36)
                        .background(DSColor.primarySoft)
                        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerSm))
                        .accessibilityHidden(true)
                    VStack(alignment: .leading) {
                        Text(item.nome).font(DSFont.body)
                        Text("Quantidade \(item.quantidade)")
                            .font(DSFont.metadata)
                            .foregroundStyle(DSColor.textSecondary)
                    }
                    Spacer()
                    Text(item.subtotalFormatado)
                        .font(DSFont.cardTitle)
                        .accessibilityLabel(item.subtotalAcessivel)
                }
                .accessibilityElement(children: .combine)
                if item.id != pedido.itens.last?.id { Divider() }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    // MARK: - Resumo financeiro

    private var resumoFinanceiro: some View {
        VStack(spacing: DSSpacing.xs) {
            HStack {
                Text("Subtotal").foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text(pedido.subtotalFormatado)
            }
            HStack {
                Text("Frete").foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text(pedido.freteFormatado)
            }
            Divider()
            HStack {
                Text("Total").font(DSFont.cardTitle)
                Spacer()
                Text(pedido.totalFormatado)
                    .font(DSFont.precoDestaque)
                    .foregroundStyle(DSColor.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Total \(pedido.totalAcessivel)")
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }
}
