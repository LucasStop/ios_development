import Testing
import Foundation
@testable import VitrineLargoOrdem

/// Testa o comportamento da `VitrineViewModel` isolada de SwiftData
/// via mocks de Repository.
@MainActor
struct VitrineViewModelTests {

    private func makeViewModel(
        produtos: [Produto] = ProdutoFixture.exemplos
    ) -> (VitrineViewModel, MockProductRepository, MockFavoriteRepository) {
        let productRepo = MockProductRepository(produtos: produtos)
        let favoriteRepo = MockFavoriteRepository()
        let viewModel = VitrineViewModel(
            productRepository: productRepo,
            favoriteRepository: favoriteRepo
        )
        return (viewModel, productRepo, favoriteRepo)
    }

    @Test func carregaProdutosNoInit() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.produtos.count == 3)
    }

    @Test func produtosFiltradosRetornaTodosQuandoSemFiltro() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.produtosFiltrados.count == 3)
    }

    @Test func produtosFiltradosFiltraPorTermoNoNome() {
        let (vm, _, _) = makeViewModel()
        vm.termoBusca = "capivara"
        #expect(vm.produtosFiltrados.count == 1)
        #expect(vm.produtosFiltrados.first?.nome == "Escultura de Capivara")
    }

    @Test func produtosFiltradosFiltraPorTermoNaCategoria() {
        let (vm, _, _) = makeViewModel()
        vm.termoBusca = "Madeira"
        #expect(vm.produtosFiltrados.count == 2)
    }

    @Test func produtosFiltradosIgnoraAcentosEMaiusculas() {
        let (vm, _, _) = makeViewModel()
        vm.termoBusca = "MADEIRA"
        #expect(vm.produtosFiltrados.count == 2)
    }

    @Test func produtosFiltradosCombinaCategoriaETermo() {
        let (vm, _, _) = makeViewModel()
        vm.categoriaSelecionada = "Madeira"
        vm.termoBusca = "Mate"
        #expect(vm.produtosFiltrados.count == 1)
        #expect(vm.produtosFiltrados.first?.nome == "Cuia de Mate")
    }

    @Test func produtosFiltradosVazioQuandoTermoNaoBate() {
        let (vm, _, _) = makeViewModel()
        vm.termoBusca = "xyzabc"
        #expect(vm.produtosFiltrados.isEmpty)
    }

    @Test func categoriasDisponiveisRetornaListaAlfabeticaSemDuplicados() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.categoriasDisponiveis == ["Comidas", "Madeira"])
    }

    @Test func alternarFavoritoDelegaAoRepositorio() {
        let (vm, _, favRepo) = makeViewModel()
        let produto = ProdutoFixture.capivara

        vm.alternarFavorito(do: produto)
        #expect(favRepo.alternarChamadoCom == [produto.id])
        #expect(vm.isFavorito(produto))

        vm.alternarFavorito(do: produto)
        #expect(favRepo.alternarChamadoCom == [produto.id, produto.id])
        #expect(!vm.isFavorito(produto))
    }

    @Test func limparFiltrosResetaCategoriaETermo() {
        let (vm, _, _) = makeViewModel()
        vm.categoriaSelecionada = "Madeira"
        vm.termoBusca = "Mate"

        vm.limparFiltros()

        #expect(vm.categoriaSelecionada == nil)
        #expect(vm.termoBusca.isEmpty)
        #expect(vm.produtosFiltrados.count == 3)
    }

    @Test func produtoComIdLocalizaPeloMockRepository() {
        let (vm, _, _) = makeViewModel()
        let encontrado = vm.produto(comId: ProdutoFixture.quibe.id)
        #expect(encontrado?.nome == "Quibe Frito")
    }
}
