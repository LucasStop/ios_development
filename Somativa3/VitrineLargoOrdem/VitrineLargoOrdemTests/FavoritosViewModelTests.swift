import Testing
import Foundation
@testable import VitrineLargoOrdem

@MainActor
struct FavoritosViewModelTests {

    private func makeViewModel() -> (FavoritosViewModel, MockProductRepository, MockFavoriteRepository) {
        let productRepo = MockProductRepository(produtos: ProdutoFixture.exemplos)
        let favRepo = MockFavoriteRepository()
        let vm = FavoritosViewModel(
            productRepository: productRepo,
            favoriteRepository: favRepo
        )
        return (vm, productRepo, favRepo)
    }

    @Test func iniciaSemFavoritos() {
        let (vm, _, _) = makeViewModel()
        #expect(vm.estaVazio)
        #expect(vm.favoritos.isEmpty)
        #expect(vm.total == 0)
    }

    @Test func carregaApenasOsProdutosFavoritados() {
        let (vm, _, favRepo) = makeViewModel()
        favRepo.favoritos.insert(ProdutoFixture.capivara.id)
        favRepo.favoritos.insert(ProdutoFixture.cuia.id)

        vm.recarregar()

        #expect(vm.total == 2)
        #expect(vm.favoritos.contains(where: { $0.id == ProdutoFixture.capivara.id }))
        #expect(vm.favoritos.contains(where: { $0.id == ProdutoFixture.cuia.id }))
    }

    @Test func removerTiraOProdutoDosFavoritos() {
        let (vm, _, favRepo) = makeViewModel()
        favRepo.favoritos.insert(ProdutoFixture.capivara.id)
        vm.recarregar()

        vm.remover(produto: ProdutoFixture.capivara)

        #expect(vm.estaVazio)
        #expect(!favRepo.favoritos.contains(ProdutoFixture.capivara.id))
    }
}
