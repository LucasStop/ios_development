import SwiftUI

struct ProdutoCardView: View {
    let produto: ProdutoArtesanal
    let aoFavoritar: () -> Void

    @ScaledMetric(relativeTo: .body) private var alturaImagem: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            imagemDoProduto

            Text(produto.nome)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text(produto.categoria)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Categoria: \(produto.categoria)")

            HStack(alignment: .center) {
                Text(produto.precoFormatado)
                    .font(.headline)
                    .foregroundStyle(.tint)
                    .accessibilityLabel(produto.precoAcessivel)

                Spacer(minLength: 8)

                BotaoFavoritoView(
                    isFavorito: produto.isFavorito,
                    nomeProduto: produto.nome,
                    acao: aoFavoritar
                )
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.4), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var imagemDoProduto: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.18), Color.accentColor.opacity(0.06)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: produto.imagemNome)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.tint)
                .padding(28)
        }
        .frame(height: alturaImagem)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel("Imagem ilustrativa de \(produto.nome), produzida por \(produto.artesao)")
    }
}

#Preview {
    ProdutoCardView(
        produto: ProdutosMockData.todos[0],
        aoFavoritar: {}
    )
    .padding()
}
