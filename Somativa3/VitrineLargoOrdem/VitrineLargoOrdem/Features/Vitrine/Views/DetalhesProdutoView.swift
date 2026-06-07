import SwiftUI

struct DetalhesProdutoView: View {
    let produtoId: UUID
    @ObservedObject var viewModel: VitrineViewModel

    @State private var mostrandoConfirmacaoContato = false

    @ScaledMetric(relativeTo: .body) private var alturaImagem: CGFloat = 240

    private var produto: ProdutoArtesanal {
        viewModel.produto(comId: produtoId) ?? ProdutosMockData.todos[0]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(produto.nome)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilitySortPriority(10)
                    .accessibilityAddTraits(.isHeader)

                imagemAmpliada
                    .accessibilitySortPriority(5)

                metadados
                    .accessibilitySortPriority(8)

                descricao
                    .accessibilitySortPriority(6)

                botaoContato
                    .accessibilitySortPriority(4)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(produto.nome)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BotaoFavoritoView(
                    isFavorito: produto.isFavorito,
                    nomeProduto: produto.nome,
                    acao: { viewModel.alternarFavorito(do: produto) }
                )
            }
        }
        .alert("Contato enviado", isPresented: $mostrandoConfirmacaoContato) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(produto.artesao) receberá sua mensagem em breve.")
        }
    }

    private var imagemAmpliada: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.22), Color.accentColor.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: produto.imagemNome)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.tint)
                .padding(50)
        }
        .frame(height: alturaImagem)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel("Imagem ampliada de \(produto.nome). \(produto.descricao)")
    }

    private var metadados: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("Artesão")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 12)
                Text(produto.artesao)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Artesão: \(produto.artesao)")

            Divider()

            HStack(alignment: .firstTextBaseline) {
                Text("Categoria")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 12)
                Text(produto.categoria)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Categoria: \(produto.categoria)")

            Divider()

            HStack(alignment: .firstTextBaseline) {
                Text("Preço")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 12)
                Text(produto.precoFormatado)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.tint)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel(produto.precoAcessivel)
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var descricao: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Sobre a peça")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Text(produto.descricao)
                .font(.body)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var botaoContato: some View {
        Button {
            mostrandoConfirmacaoContato = true
        } label: {
            Label("Entrar em contato com o Artesão", systemImage: "envelope.fill")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(.accentColor)
        .accessibilityHint("Abre uma confirmação para contatar \(produto.artesao).")
    }
}

#Preview {
    NavigationStack {
        DetalhesProdutoView(
            produtoId: ProdutosMockData.todos[0].id,
            viewModel: VitrineViewModel()
        )
    }
}
