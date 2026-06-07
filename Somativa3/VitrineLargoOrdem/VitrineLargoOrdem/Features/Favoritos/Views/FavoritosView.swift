import SwiftUI

struct FavoritosView: View {
    @ObservedObject var viewModel: FavoritosViewModel
    @ObservedObject var carrinhoViewModel: CarrinhoViewModel
    @ObservedObject var vitrineViewModel: VitrineViewModel

    private let colunas = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.estaVazio {
                    estadoVazio
                } else {
                    grid
                }
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Favoritos")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { viewModel.recarregar() }
    }

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Nenhum favorito ainda", systemImage: "heart")
        } description: {
            Text("Toque no coração de um produto na vitrine para adicioná-lo aos favoritos.")
        }
        .accessibilityElement(children: .combine)
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: colunas, spacing: DSSpacing.md) {
                ForEach(viewModel.favoritos) { produto in
                    NavigationLink {
                        DetalhesProdutoView(
                            produtoId: produto.id,
                            viewModel: vitrineViewModel,
                            carrinhoViewModel: carrinhoViewModel
                        )
                    } label: {
                        ProdutoCardView(
                            produto: produto,
                            isFavorito: true,
                            aoFavoritar: {
                                viewModel.remover(produto: produto)
                                vitrineViewModel.recarregar()
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Abre a tela de detalhes da peça.")
                }
            }
            .padding(DSSpacing.md)
        }
    }
}
