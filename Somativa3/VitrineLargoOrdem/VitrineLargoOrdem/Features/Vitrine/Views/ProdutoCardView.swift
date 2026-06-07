import SwiftUI

struct ProdutoCardView: View {
    let produto: Produto
    let isFavorito: Bool
    let aoFavoritar: () -> Void

    @ScaledMetric(relativeTo: .body) private var alturaImagem: CGFloat = 130

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            imagemDoProduto

            Text(produto.nome)
                .font(DSFont.cardTitle)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isHeader)

            Text(produto.categoria)
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityLabel("Categoria: \(produto.categoria)")

            HStack(alignment: .center) {
                Text(produto.precoFormatado)
                    .font(DSFont.preco)
                    .foregroundStyle(DSColor.primary)
                    .accessibilityLabel(produto.precoAcessivel)

                Spacer(minLength: DSSpacing.xs)

                BotaoFavoritoView(
                    isFavorito: isFavorito,
                    nomeProduto: produto.nome,
                    acao: aoFavoritar
                )
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var imagemDoProduto: some View {
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
                .padding(28)
        }
        .frame(height: alturaImagem)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd, style: .continuous))
        .accessibilityElement()
        .accessibilityLabel("Imagem ilustrativa de \(produto.nome), produzida por \(produto.artesao)")
    }
}
