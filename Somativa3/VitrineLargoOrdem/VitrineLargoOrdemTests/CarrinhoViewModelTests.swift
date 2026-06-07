import Testing
import Foundation
@testable import VitrineLargoOrdem

/// Testes do carrinho — cobre add/remove/qty/totais/frete e estado vazio.
@MainActor
struct CarrinhoViewModelTests {

    private func makeViewModel() -> (CarrinhoViewModel, MockCartRepository) {
        let repo = MockCartRepository()
        let vm = CarrinhoViewModel(cartRepository: repo)
        return (vm, repo)
    }

    @Test func carrinhoIniciaVazio() {
        let (vm, _) = makeViewModel()
        #expect(vm.estaVazio)
        #expect(vm.itens.isEmpty)
        #expect(vm.totalDeItens == 0)
        #expect(vm.subtotal == 0)
        #expect(vm.total == 0)
    }

    @Test func adicionarCriaNovoItemQuandoNaoExiste() {
        let (vm, _) = makeViewModel()

        vm.adicionar(produto: ProdutoFixture.capivara)

        #expect(vm.itens.count == 1)
        #expect(vm.totalDeItens == 1)
        #expect(vm.subtotal == 85.00)
    }

    @Test func adicionarIncrementaQuandoProdutoJaEstaNoCarrinho() {
        let (vm, _) = makeViewModel()

        vm.adicionar(produto: ProdutoFixture.capivara)
        vm.adicionar(produto: ProdutoFixture.capivara)
        vm.adicionar(produto: ProdutoFixture.capivara)

        #expect(vm.itens.count == 1, "Mesmo produto adicionado tres vezes deve resultar em 1 item")
        #expect(vm.totalDeItens == 3)
        #expect(vm.subtotal == 255.00)
    }

    @Test func adicionarRespeitaQuantidadeCustom() {
        let (vm, _) = makeViewModel()

        vm.adicionar(produto: ProdutoFixture.quibe, quantidade: 5)

        #expect(vm.totalDeItens == 5)
        #expect(vm.subtotal == 60.00)
    }

    @Test func produtosDistintosCriamItensSeparados() {
        let (vm, _) = makeViewModel()

        vm.adicionar(produto: ProdutoFixture.capivara)
        vm.adicionar(produto: ProdutoFixture.quibe)

        #expect(vm.itens.count == 2)
        #expect(vm.totalDeItens == 2)
        #expect(vm.subtotal == 97.00)
    }

    @Test func incrementarAumentaQuantidadeDoItem() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)

        guard let item = vm.itens.first else { Issue.record("Carrinho deveria ter 1 item"); return }
        vm.incrementar(item: item)

        #expect(vm.itens.first?.quantidade == 2)
        #expect(vm.totalDeItens == 2)
    }

    @Test func decrementarReduzQuantidade() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara, quantidade: 3)

        guard let item = vm.itens.first else { Issue.record("Carrinho deveria ter item"); return }
        vm.decrementar(item: item)

        #expect(vm.itens.first?.quantidade == 2)
    }

    @Test func decrementarParaZeroRemoveOItem() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)

        guard let item = vm.itens.first else { Issue.record("Carrinho deveria ter item"); return }
        vm.decrementar(item: item)

        #expect(vm.itens.isEmpty)
        #expect(vm.estaVazio)
    }

    @Test func removerTiraOItemPorCompleto() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara, quantidade: 5)
        vm.adicionar(produto: ProdutoFixture.quibe)

        guard let capivara = vm.itens.first(where: { $0.nome == ProdutoFixture.capivara.nome }) else {
            Issue.record("Capivara deveria estar no carrinho"); return
        }
        vm.remover(item: capivara)

        #expect(vm.itens.count == 1)
        #expect(vm.itens.first?.nome == "Quibe Frito")
    }

    @Test func limparEsvaziaOCarrinho() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)
        vm.adicionar(produto: ProdutoFixture.quibe)
        vm.adicionar(produto: ProdutoFixture.cuia)

        vm.limpar()

        #expect(vm.itens.isEmpty)
        #expect(vm.totalDeItens == 0)
        #expect(vm.subtotal == 0)
    }

    @Test func totalIncluiFreteQuandoTemItens() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)

        #expect(vm.subtotal == 85.00)
        #expect(vm.total == 100.00, "Subtotal 85 + frete 15 = 100")
    }

    @Test func totalIgnoraFreteQuandoCarrinhoVazio() {
        let (vm, _) = makeViewModel()
        #expect(vm.total == 0)
    }

    @Test func subtotalAcessivelFormataComoTexto() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)
        #expect(vm.subtotalAcessivel == "Preço: 85 reais")
    }

    @Test func totalAcessivelInclueFrete() {
        let (vm, _) = makeViewModel()
        vm.adicionar(produto: ProdutoFixture.capivara)
        #expect(vm.totalAcessivel == "Preço: 100 reais")
    }
}
