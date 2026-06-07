import SwiftUI

struct VitrineView: View {
    @StateObject private var viewModel = VitrineViewModel()

    private let colunas = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: colunas, spacing: 16) {
                    ForEach(viewModel.produtosFiltrados) { produto in
                        NavigationLink {
                            DetalhesProdutoView(produtoId: produto.id, viewModel: viewModel)
                        } label: {
                            ProdutoCardView(
                                produto: produto,
                                aoFavoritar: { viewModel.alternarFavorito(do: produto) }
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Abre a tela de detalhes da peça.")
                    }
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Feira do Largo")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.termoBusca,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar por nome ou categoria"
            )
            .overlay {
                if viewModel.produtosFiltrados.isEmpty && !viewModel.termoBusca.isEmpty {
                    estadoVazio
                }
            }
        }
    }

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Nenhum produto encontrado", systemImage: "magnifyingglass")
        } description: {
            Text("Tente buscar por outro nome ou categoria, como Madeira, Arte ou Comidas.")
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VitrineView()
}
