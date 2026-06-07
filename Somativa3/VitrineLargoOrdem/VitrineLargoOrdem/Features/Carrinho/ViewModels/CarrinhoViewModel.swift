import Foundation
import Combine

/// Gerencia o carrinho do usuário e o resumo financeiro.
@MainActor
final class CarrinhoViewModel: ObservableObject {

    @Published private(set) var itens: [CartItem] = []
    @Published private(set) var totalDeItens: Int = 0

    /// Frete fixo no MVP. V2 traz cálculo real via CEP.
    let freteFixo: Double = 15.00

    private let cartRepository: CartRepository

    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
        recarregar()
    }

    var subtotal: Double { itens.reduce(0) { $0 + $1.subtotal } }
    var total: Double { itens.isEmpty ? 0 : subtotal + freteFixo }
    var estaVazio: Bool { itens.isEmpty }

    var subtotalFormatado: String { PrecoFormatter.formatado(subtotal) }
    var subtotalAcessivel: String { PrecoFormatter.acessivel(subtotal) }
    var freteFormatado: String { PrecoFormatter.formatado(freteFixo) }
    var freteAcessivel: String { PrecoFormatter.acessivel(freteFixo) }
    var totalFormatado: String { PrecoFormatter.formatado(total) }
    var totalAcessivel: String { PrecoFormatter.acessivel(total) }

    func recarregar() {
        itens = cartRepository.itens()
        totalDeItens = cartRepository.totalDeItens()
    }

    func adicionar(produto: Produto, quantidade: Int = 1) {
        cartRepository.adicionar(produto: produto, quantidade: quantidade)
        recarregar()
    }

    func incrementar(item: CartItem) {
        cartRepository.atualizar(produtoId: item.produtoId, quantidade: item.quantidade + 1)
        recarregar()
    }

    func decrementar(item: CartItem) {
        cartRepository.atualizar(produtoId: item.produtoId, quantidade: item.quantidade - 1)
        recarregar()
    }

    func remover(item: CartItem) {
        cartRepository.remover(produtoId: item.produtoId)
        recarregar()
    }

    func limpar() {
        cartRepository.limpar()
        recarregar()
    }
}
