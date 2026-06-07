import SwiftUI

struct CartItemRowView: View {
    let item: CartItem
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onRemove: () -> Void

    @ScaledMetric(relativeTo: .body) private var alturaImagem: CGFloat = 72

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            thumbnail
            informacoes
            Spacer(minLength: DSSpacing.xs)
            controlesQuantidade
        }
        .padding(DSSpacing.sm)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var thumbnail: some View {
        ZStack {
            LinearGradient(
                colors: [DSColor.primarySoft, DSColor.primaryFaint],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: item.imagemNome)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(DSColor.primary)
                .padding(DSSpacing.sm)
        }
        .frame(width: alturaImagem, height: alturaImagem)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerSm, style: .continuous))
        .accessibilityHidden(true)
    }

    private var informacoes: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text(item.nome)
                .font(DSFont.cardTitle)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(2)

            Text(PrecoFormatter.formatado(item.subtotal))
                .font(DSFont.preco)
                .foregroundStyle(DSColor.primary)
                .accessibilityLabel("Subtotal: \(PrecoFormatter.acessivel(item.subtotal))")
        }
    }

    private var controlesQuantidade: some View {
        VStack(spacing: DSSpacing.xs) {
            HStack(spacing: DSSpacing.xs) {
                Button {
                    onDecrement()
                } label: {
                    Image(systemName: item.quantidade > 1 ? "minus.circle.fill" : "trash.circle.fill")
                        .font(.title2)
                        .foregroundStyle(item.quantidade > 1 ? DSColor.primary : DSColor.danger)
                        .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(item.quantidade > 1
                                    ? "Diminuir quantidade de \(item.nome)"
                                    : "Remover \(item.nome) do carrinho")

                Text("\(item.quantidade)")
                    .font(DSFont.cardTitle)
                    .frame(minWidth: 24)
                    .accessibilityLabel("\(item.quantidade) unidades de \(item.nome)")

                Button {
                    onIncrement()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DSColor.primary)
                        .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Aumentar quantidade de \(item.nome)")
            }
        }
    }
}
