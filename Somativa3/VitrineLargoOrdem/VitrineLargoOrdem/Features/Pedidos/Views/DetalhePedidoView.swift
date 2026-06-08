import SwiftUI

struct DetalhePedidoView: View {
    let pedido: Pedido
    @ObservedObject var viewModel: PedidosViewModel
    @State private var mostrandoCancelar = false

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                cabecalho
                timeline
                itens
                resumo
                acoes
            }
            .padding(DSSpacing.md)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Pedido \(pedido.numero)")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancelar pedido?",
                            isPresented: $mostrandoCancelar,
                            titleVisibility: .visible) {
            Button("Cancelar pedido", role: .destructive) {
                viewModel.cancelar(pedido)
            }
            Button("Manter pedido", role: .cancel) {}
        } message: {
            Text("Esta ação é definitiva no MVP. Em produção exigiria confirmação com o artesão.")
        }
    }

    // MARK: - Cabeçalho

    private var cabecalho: some View {
        VStack(spacing: DSSpacing.xs) {
            Text(pedido.numero)
                .font(DSFont.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            Text(pedido.criadoEm.formatted(date: .abbreviated, time: .shortened))
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Timeline

    private var timeline: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            secaoHeader("Andamento")

            if pedido.status == .cancelado {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "xmark.octagon.fill")
                        .foregroundStyle(.red)
                    Text("Pedido cancelado em \(pedido.atualizadoEm.formatted(date: .abbreviated, time: .shortened))")
                }
                .padding(DSSpacing.md)
                .background(Color.red.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd))
            } else {
                VStack(spacing: 0) {
                    ForEach(StatusPedido.etapas.indices, id: \.self) { indice in
                        passoTimeline(indice: indice)
                    }
                }
            }
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    private func passoTimeline(indice: Int) -> some View {
        let etapa = StatusPedido.etapas[indice]
        let atual = pedido.status.indiceNaTimeline ?? 0
        let concluido = indice < atual
        let emAndamento = indice == atual
        let futuro = indice > atual
        let cor: Color = concluido ? DSColor.primary :
                         emAndamento ? DSColor.primary :
                         DSColor.border

        return HStack(alignment: .top, spacing: DSSpacing.md) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(emAndamento ? DSColor.primary : (concluido ? DSColor.primary : DSColor.surface))
                        .frame(width: 32, height: 32)
                    Image(systemName: etapa.simbolo)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(emAndamento || concluido ? Color.white : DSColor.textSecondary)
                }
                if indice < StatusPedido.etapas.count - 1 {
                    Rectangle()
                        .fill(cor)
                        .frame(width: 2)
                        .frame(minHeight: 36)
                }
            }

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(etapa.titulo)
                    .font(DSFont.cardTitle)
                    .foregroundStyle(futuro ? DSColor.textSecondary : DSColor.textPrimary)
                Text(descricao(etapa, atual: atual, indice: indice))
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
            }
            .padding(.bottom, DSSpacing.md)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(etapa.titulo). \(emAndamento ? "Em andamento" : (concluido ? "Concluído" : "Aguardando"))")
    }

    private func descricao(_ etapa: StatusPedido, atual: Int, indice: Int) -> String {
        if indice < atual { return "Concluído" }
        if indice == atual {
            switch etapa {
            case .recebido: return "Pagamento confirmado, aguardando o artesão"
            case .emProducao: return "O artesão está preparando sua peça com carinho"
            case .despachado: return "Pedido a caminho — código de rastreio chega por e-mail"
            case .entregue: return "Pedido entregue!"
            case .cancelado: return "Pedido cancelado"
            }
        }
        return "Em breve"
    }

    // MARK: - Itens

    private var itens: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            secaoHeader("Itens (\(pedido.quantidadeTotal))")
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
                .accessibilityLabel("\(item.nome), quantidade \(item.quantidade), subtotal \(item.subtotalAcessivel)")
                if item.id != pedido.itens.last?.id { Divider() }
            }
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    // MARK: - Resumo financeiro + endereço

    private var resumo: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            secaoHeader("Entrega")
            VStack(alignment: .leading, spacing: 2) {
                Text(pedido.enderecoLinha1).font(DSFont.body)
                Text(pedido.enderecoLinha2)
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
            }
            Divider()
            secaoHeader("Pagamento")
            HStack {
                Image(systemName: pedido.formaPagamento.simbolo).foregroundStyle(DSColor.primary)
                Text(pedido.formaPagamento.titulo)
                Spacer()
            }
            Divider()
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

    @ViewBuilder
    private var acoes: some View {
        if !pedido.status.ehFinal {
            VStack(spacing: DSSpacing.sm) {
                Button {
                    viewModel.avancarStatus(do: pedido)
                } label: {
                    Label("Avançar status (demo)", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
                .tint(DSColor.primary)
                .accessibilityHint("Avanca artificialmente o status do pedido. Util para demonstracoes.")

                Button(role: .destructive) {
                    mostrandoCancelar = true
                } label: {
                    Label("Cancelar pedido", systemImage: "xmark.octagon")
                        .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Cancela o pedido. Pede confirmacao antes.")
            }
        }
    }

    private func secaoHeader(_ titulo: String) -> some View {
        Text(titulo.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(DSColor.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }
}
