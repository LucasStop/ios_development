import SwiftUI

/// Fluxo de checkout em 4 etapas (endereço → pagamento → revisão → confirmação).
struct CheckoutView: View {
    @ObservedObject var viewModel: CheckoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var formEnderecoAberto: Bool = false
    let dependencies: AppDependencies

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progresso
                Divider()
                conteudo
                Divider()
                barraInferior
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Finalizar pedido")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.etapaAtual != .confirmacao {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.etapaAtual == .confirmacao)
            .sheet(isPresented: $formEnderecoAberto) {
                EnderecoFormView(
                    viewModel: dependencies.makeEnderecoFormViewModel(
                        usuarioId: dependencies.authService.usuarioAtual?.id ?? UUID()
                    )
                )
            }
        }
    }

    // MARK: - Progresso

    private var progresso: some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                ForEach(0..<viewModel.totalEtapas, id: \.self) { indice in
                    Capsule()
                        .fill(indice <= viewModel.indiceEtapa ? DSColor.primary : DSColor.border)
                        .frame(height: 6)
                        .animation(.easeInOut, value: viewModel.indiceEtapa)
                }
            }
            HStack {
                Text("Etapa \(min(viewModel.indiceEtapa + 1, viewModel.totalEtapas)) de \(viewModel.totalEtapas)")
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text(viewModel.etapaAtual.titulo)
                    .font(DSFont.metadata.weight(.semibold))
                    .foregroundStyle(DSColor.primary)
            }
        }
        .padding(DSSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Progresso do checkout. \(viewModel.etapaAtual.titulo). Etapa \(viewModel.indiceEtapa + 1) de \(viewModel.totalEtapas).")
    }

    // MARK: - Conteúdo por etapa

    @ViewBuilder
    private var conteudo: some View {
        switch viewModel.etapaAtual {
        case .endereco: etapaEndereco
        case .pagamento: etapaPagamento
        case .revisao: etapaRevisao
        case .confirmacao: etapaConfirmacao
        }
    }

    private var etapaEndereco: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                cabecalhoEtapa(simbolo: "house.fill",
                               titulo: "Para onde vamos entregar?",
                               subtitulo: "Escolha um dos endereços cadastrados ou adicione um novo.")

                if viewModel.enderecosDisponiveis.isEmpty {
                    ContentUnavailableView {
                        Label("Sem endereços", systemImage: "house")
                    } description: {
                        Text("Adicione um endereço para continuar com o pedido.")
                    }
                } else {
                    ForEach(viewModel.enderecosDisponiveis) { endereco in
                        Button {
                            viewModel.enderecoSelecionado = endereco
                        } label: {
                            cartaoEndereco(endereco)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button {
                    formEnderecoAberto = true
                } label: {
                    Label("Adicionar novo endereço", systemImage: "plus")
                        .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
                }
                .buttonStyle(.bordered)
                .tint(DSColor.primary)
            }
            .padding(DSSpacing.md)
        }
    }

    private func cartaoEndereco(_ endereco: Endereco) -> some View {
        let selecionado = viewModel.enderecoSelecionado?.id == endereco.id
        return HStack(spacing: DSSpacing.sm) {
            Image(systemName: selecionado ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(selecionado ? DSColor.primary : DSColor.textSecondary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                HStack {
                    Text(endereco.apelido).font(DSFont.cardTitle)
                    if endereco.ehPadrao {
                        Text("Padrão")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, DSSpacing.xs)
                            .padding(.vertical, 2)
                            .background(DSColor.primarySoft)
                            .foregroundStyle(DSColor.primary)
                            .clipShape(Capsule())
                    }
                }
                Text(endereco.linhaPrincipal).font(DSFont.body)
                Text(endereco.linhaSecundaria)
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
            }
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg)
                .strokeBorder(selecionado ? DSColor.primary : DSColor.border, lineWidth: selecionado ? 2 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(endereco.descricaoAcessivel). \(selecionado ? "Selecionado." : "Toque para selecionar.")")
        .accessibilityAddTraits(selecionado ? [.isSelected, .isButton] : .isButton)
    }

    private var etapaPagamento: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                cabecalhoEtapa(simbolo: "creditcard.fill",
                               titulo: "Como você quer pagar?",
                               subtitulo: "No MVP a confirmação é fictícia — o gateway real entra na V2.")

                ForEach(FormaPagamento.allCases) { forma in
                    Button {
                        viewModel.formaPagamento = forma
                    } label: {
                        cartaoPagamento(forma)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.md)
        }
    }

    private func cartaoPagamento(_ forma: FormaPagamento) -> some View {
        let selecionado = viewModel.formaPagamento == forma
        return HStack(spacing: DSSpacing.md) {
            Image(systemName: forma.simbolo)
                .font(.title2)
                .foregroundStyle(DSColor.primary)
                .frame(width: 32)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(forma.titulo).font(DSFont.cardTitle)
                Text(descricaoPagamento(forma))
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
            }
            Spacer()
            Image(systemName: selecionado ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selecionado ? DSColor.primary : DSColor.textSecondary)
                .accessibilityHidden(true)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
        .overlay {
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg)
                .strokeBorder(selecionado ? DSColor.primary : DSColor.border, lineWidth: selecionado ? 2 : 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(forma.titulo). \(descricaoPagamento(forma)). \(selecionado ? "Selecionado." : "")")
        .accessibilityAddTraits(selecionado ? [.isSelected, .isButton] : .isButton)
    }

    private func descricaoPagamento(_ forma: FormaPagamento) -> String {
        switch forma {
        case .pix: return "Aprovação instantânea via QR Code"
        case .cartaoCredito: return "Em até 3x sem juros"
        case .cartaoDebito: return "Débito automático na compra"
        case .boleto: return "Compensação em até 2 dias úteis"
        }
    }

    private var etapaRevisao: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                cabecalhoEtapa(simbolo: "checklist",
                               titulo: "Confira antes de confirmar",
                               subtitulo: "Tudo certo? Ao confirmar você aceita nossos termos.")

                if let endereco = viewModel.enderecoSelecionado {
                    secaoRevisao(titulo: "Entrega", simbolo: "house.fill") {
                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                            Text(endereco.apelido).font(DSFont.cardTitle)
                            Text(endereco.linhaPrincipal).font(DSFont.body)
                            Text(endereco.linhaSecundaria)
                                .font(DSFont.metadata)
                                .foregroundStyle(DSColor.textSecondary)
                        }
                    }
                }

                secaoRevisao(titulo: "Pagamento", simbolo: viewModel.formaPagamento.simbolo) {
                    Text(viewModel.formaPagamento.titulo).font(DSFont.body)
                }

                secaoRevisao(titulo: "Total do pedido", simbolo: "cart.fill") {
                    Text(PrecoFormatter.formatado(totalDoPedido()))
                        .font(DSFont.precoDestaque)
                        .foregroundStyle(DSColor.primary)
                        .accessibilityLabel(PrecoFormatter.acessivel(totalDoPedido()))
                }

                Toggle(isOn: $viewModel.aceitouTermos) {
                    Text("Li e aceito os termos de uso e a política de privacidade.")
                        .font(DSFont.body)
                }
                .accessibilityHint("Obrigatório para confirmar o pedido.")
                .padding(DSSpacing.md)
                .background(DSColor.background)
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
            }
            .padding(DSSpacing.md)
        }
    }

    private func totalDoPedido() -> Double {
        // Lê do carrinhoViewModel via reflection — simplificação:
        // o checkout sabe o total porque o construímos com base no carrinho.
        viewModel.enderecoSelecionado == nil ? 0 : (dependencies.authService.usuarioAtual?.id == nil ? 0 : carrinhoTotalSafe())
    }

    private func carrinhoTotalSafe() -> Double {
        // Acesso via dependencies para evitar acoplar o checkout ao
        // ViewModel do carrinho diretamente neste card de revisão.
        let cart = dependencies.cartRepository
        let itens = cart.itens()
        let subtotal = itens.reduce(0.0) { $0 + $1.subtotal }
        return itens.isEmpty ? 0 : subtotal + 15.00 // frete fixo MVP
    }

    private func secaoRevisao<Content: View>(titulo: String, simbolo: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Image(systemName: simbolo).foregroundStyle(DSColor.primary).accessibilityHidden(true)
                Text(titulo.uppercased())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(DSColor.textSecondary)
                    .accessibilityAddTraits(.isHeader)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
    }

    @ViewBuilder
    private var etapaConfirmacao: some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [DSColor.primarySoft, DSColor.primaryFaint],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 160, height: 160)
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(DSColor.primary)
                    .frame(width: 88, height: 88)
            }
            .accessibilityHidden(true)

            VStack(spacing: DSSpacing.sm) {
                Text("Pedido confirmado!")
                    .font(DSFont.screenTitle)
                    .accessibilityAddTraits(.isHeader)
                if let pedido = viewModel.pedidoCriado {
                    Text("Número \(pedido.numero)")
                        .font(DSFont.cardTitle)
                        .foregroundStyle(DSColor.primary)
                    Text(PrecoFormatter.formatado(pedido.total))
                        .font(DSFont.precoDestaque)
                        .accessibilityLabel(PrecoFormatter.acessivel(pedido.total))
                    Text("Acompanhe o andamento na aba Perfil → Meus pedidos.")
                        .font(DSFont.body)
                        .foregroundStyle(DSColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DSSpacing.lg)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Concluir")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .font(DSFont.buttonLabel)
            }
            .buttonStyle(.borderedProminent)
            .tint(DSColor.primary)
            .padding(DSSpacing.md)
            .accessibilityHint("Fecha a tela e volta para o carrinho ja vazio.")
        }
    }

    // MARK: - Barra inferior

    @ViewBuilder
    private var barraInferior: some View {
        if viewModel.etapaAtual != .confirmacao {
            HStack(spacing: DSSpacing.sm) {
                if viewModel.podeVoltar {
                    Button {
                        viewModel.voltar()
                    } label: {
                        Label("Voltar", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint("Volta para a etapa anterior.")
                }
                Button {
                    viewModel.avancar()
                } label: {
                    HStack {
                        if viewModel.processando { ProgressView().tint(.white) }
                        Text(viewModel.etapaAtual == .revisao ? "Confirmar pedido" : "Continuar")
                            .font(DSFont.buttonLabel)
                    }
                    .frame(maxWidth: .infinity, minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(DSColor.primary)
                .disabled(!viewModel.podeAvancar || viewModel.processando)
                .accessibilityHint(viewModel.etapaAtual == .revisao
                                   ? "Confirma o pedido com os dados informados."
                                   : "Avanca para a proxima etapa.")
            }
            .padding(DSSpacing.md)
            .background(DSColor.background)
        }
    }

    private func cabecalhoEtapa(simbolo: String, titulo: String, subtitulo: String) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Image(systemName: simbolo)
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(DSColor.primary)
                .accessibilityHidden(true)
            Text(titulo)
                .font(DSFont.sectionTitle)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(subtitulo)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, DSSpacing.sm)
    }
}
