import SwiftUI

struct VitrineView: View {
    @ObservedObject var viewModel: VitrineViewModel
    @ObservedObject var carrinhoViewModel: CarrinhoViewModel

    private let colunas = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !viewModel.categoriasDisponiveis.isEmpty {
                    CategoryChipsView(
                        categorias: viewModel.categoriasDisponiveis,
                        selecionada: viewModel.categoriaSelecionada,
                        onSelecionar: { viewModel.categoriaSelecionada = $0 }
                    )
                    .background(DSColor.groupedBackground)
                }

                conteudoPrincipal
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Feira do Largo")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $viewModel.termoBusca,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Buscar por nome ou categoria"
            )
        }
        .onAppear { viewModel.recarregar() }
    }

    @ViewBuilder
    private var conteudoPrincipal: some View {
        if viewModel.carregando {
            ScrollView { SkeletonGridView(quantidade: 6) }
        } else if viewModel.produtosFiltrados.isEmpty {
            estadoVazio
        } else {
            ScrollView {
                LazyVGrid(columns: colunas, spacing: DSSpacing.md) {
                    ForEach(viewModel.produtosFiltrados) { produto in
                        NavigationLink {
                            DetalhesProdutoView(
                                produtoId: produto.id,
                                viewModel: viewModel,
                                carrinhoViewModel: carrinhoViewModel
                            )
                        } label: {
                            ProdutoCardView(
                                produto: produto,
                                isFavorito: viewModel.isFavorito(produto),
                                aoFavoritar: { viewModel.alternarFavorito(do: produto) }
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

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Nenhum produto encontrado", systemImage: "magnifyingglass")
        } description: {
            Text(mensagemDoEstadoVazio)
        } actions: {
            Button("Limpar filtros") {
                viewModel.limparFiltros()
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var mensagemDoEstadoVazio: String {
        if let categoria = viewModel.categoriaSelecionada, !viewModel.termoBusca.isEmpty {
            return "Nenhum resultado para \"\(viewModel.termoBusca)\" em \(categoria). Toque em Limpar filtros para ver tudo."
        }
        if let categoria = viewModel.categoriaSelecionada {
            return "Nenhum produto na categoria \(categoria) no momento."
        }
        return "Tente buscar por outro nome ou categoria, como Madeira, Arte ou Comidas."
    }
}
