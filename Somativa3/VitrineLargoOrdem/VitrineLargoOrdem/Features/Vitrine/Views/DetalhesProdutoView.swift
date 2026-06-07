import SwiftUI

struct DetalhesProdutoView: View {
    let produtoId: UUID
    @ObservedObject var viewModel: VitrineViewModel
    @ObservedObject var carrinhoViewModel: CarrinhoViewModel

    @State private var mostrandoConfirmacaoContato = false
    @State private var mostrandoToastCarrinho = false

    @ScaledMetric(relativeTo: .body) private var alturaImagem: CGFloat = 240

    var body: some View {
        Group {
            if let produto = viewModel.produto(comId: produtoId) {
                conteudo(produto: produto)
            } else {
                ContentUnavailableView("Produto não encontrado",
                                       systemImage: "questionmark.folder",
                                       description: Text("Não foi possível carregar os detalhes deste produto."))
            }
        }
    }

    @ViewBuilder
    private func conteudo(produto: Produto) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                Text(produto.nome)
                    .font(DSFont.screenTitle)
                    .foregroundStyle(DSColor.textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilitySortPriority(10)
                    .accessibilityAddTraits(.isHeader)

                imagemAmpliada(produto: produto)
                    .accessibilitySortPriority(5)

                metadados(produto: produto)
                    .accessibilitySortPriority(8)

                descricao(produto: produto)
                    .accessibilitySortPriority(6)

                botaoAdicionarCarrinho(produto: produto)
                    .accessibilitySortPriority(7)

                botaoContato(produto: produto)
                    .accessibilitySortPriority(4)
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle(produto.nome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BotaoFavoritoView(
                    isFavorito: viewModel.isFavorito(produto),
                    nomeProduto: produto.nome,
                    acao: { viewModel.alternarFavorito(do: produto) }
                )
            }
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(
                    item: textoCompartilhamento(produto),
                    subject: Text(produto.nome),
                    message: Text("Confira esta peça da Feira do Largo da Ordem.")
                ) {
                    Image(systemName: "square.and.arrow.up")
                        .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                }
                .accessibilityLabel("Compartilhar \(produto.nome)")
                .accessibilityHint("Abre as opcoes para compartilhar este produto.")
            }
        }
        .alert("Contato enviado", isPresented: $mostrandoConfirmacaoContato) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(produto.artesao) receberá sua mensagem em breve.")
        }
        .alert("Adicionado ao carrinho", isPresented: $mostrandoToastCarrinho) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(produto.nome) foi adicionado ao seu carrinho.")
        }
    }

    private func imagemAmpliada(produto: Produto) -> some View {
        ZStack {
            LinearGradient(
                colors: [DSColor.primarySoft, DSColor.primaryFaint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: produto.imagemNome)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(DSColor.primary)
                .padding(50)
        }
        .frame(height: alturaImagem)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerXl, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel("Imagem ampliada de \(produto.nome). \(produto.descricao)")
    }

    private func metadados(produto: Produto) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            metadadoLinha(rotulo: "Artesão", valor: produto.artesao)
            Divider()
            metadadoLinha(rotulo: "Categoria", valor: produto.categoria)
            Divider()
            metadadoLinha(rotulo: "Disponibilidade",
                          valor: produto.temEstoque ? "\(produto.estoque) disponíveis" : "Esgotado")
            Divider()
            HStack(alignment: .firstTextBaseline) {
                Text("Preço")
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                Spacer(minLength: DSSpacing.sm)
                Text(produto.precoFormatado)
                    .font(DSFont.precoDestaque)
                    .foregroundStyle(DSColor.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(produto.precoAcessivel)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private func metadadoLinha(rotulo: String, valor: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(rotulo)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
            Spacer(minLength: DSSpacing.sm)
            Text(valor)
                .font(DSFont.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rotulo): \(valor)")
    }

    private func descricao(produto: Produto) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Sobre a peça")
                .font(DSFont.cardTitle)
                .accessibilityAddTraits(.isHeader)

            Text(produto.descricao)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private func botaoAdicionarCarrinho(produto: Produto) -> some View {
        Button {
            carrinhoViewModel.adicionar(produto: produto)
            mostrandoToastCarrinho = true
        } label: {
            Label("Adicionar ao carrinho", systemImage: "cart.badge.plus")
                .font(DSFont.buttonLabel)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(DSColor.primary)
        .disabled(!produto.temEstoque)
        .accessibilityHint(produto.temEstoque
                           ? "Adiciona uma unidade de \(produto.nome) ao carrinho."
                           : "Produto esgotado.")
    }

    private func textoCompartilhamento(_ produto: Produto) -> String {
        """
        \(produto.nome) — por \(produto.artesao)
        \(produto.precoFormatado) · \(produto.categoria)

        \(produto.descricao)

        Encontrado na Vitrine da Feira do Largo da Ordem.
        """
    }

    private func botaoContato(produto: Produto) -> some View {
        Button {
            mostrandoConfirmacaoContato = true
        } label: {
            Label("Entrar em contato com o Artesão", systemImage: "envelope.fill")
                .font(DSFont.buttonLabel)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.bordered)
        .tint(DSColor.primary)
        .accessibilityHint("Abre uma confirmação para contatar \(produto.artesao).")
    }
}
