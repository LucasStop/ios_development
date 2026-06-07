import SwiftUI

struct BotaoFavoritoView: View {
    let isFavorito: Bool
    let nomeProduto: String
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            Image(systemName: isFavorito ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorito ? DSColor.favoriteActive : DSColor.favoriteInactive)
                .symbolEffect(.bounce, value: isFavorito)
                .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(isFavorito ? "Remover \(nomeProduto) dos favoritos" : "Adicionar \(nomeProduto) aos favoritos")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    HStack {
        BotaoFavoritoView(isFavorito: false, nomeProduto: "Capivara de Madeira") {}
        BotaoFavoritoView(isFavorito: true, nomeProduto: "Quibe") {}
    }
}
