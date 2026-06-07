import Foundation
import SwiftData

/// Contrato para o carrinho de compras do usuário.
@MainActor
protocol CartRepository: AnyObject {
    /// Itens atualmente no carrinho.
    func itens() -> [CartItem]

    /// Adiciona ou incrementa a quantidade de um produto no carrinho.
    /// Se já existir, soma a quantidade existente.
    func adicionar(produto: Produto, quantidade: Int)

    /// Atualiza a quantidade de um item existente. Se for 0 ou menor, remove.
    func atualizar(produtoId: UUID, quantidade: Int)

    /// Remove completamente o item do carrinho.
    func remover(produtoId: UUID)

    /// Limpa todo o carrinho.
    func limpar()

    /// Quantidade total de unidades no carrinho (soma de quantidades).
    func totalDeItens() -> Int
}

@MainActor
final class LocalCartRepository: CartRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func itens() -> [CartItem] {
        let descritor = FetchDescriptor<CartItem>(
            sortBy: [SortDescriptor(\.adicionadoEm, order: .forward)]
        )
        return (try? context.fetch(descritor)) ?? []
    }

    func adicionar(produto: Produto, quantidade: Int = 1) {
        let id = produto.id
        let descritor = FetchDescriptor<CartItem>(
            predicate: #Predicate { $0.produtoId == id }
        )
        if let existente = try? context.fetch(descritor).first {
            existente.quantidade += quantidade
        } else {
            context.insert(CartItem(
                produtoId: produto.id,
                nome: produto.nome,
                imagemNome: produto.imagemNome,
                precoUnitario: produto.preco,
                quantidade: quantidade
            ))
        }
        try? context.save()
    }

    func atualizar(produtoId: UUID, quantidade: Int) {
        let descritor = FetchDescriptor<CartItem>(
            predicate: #Predicate { $0.produtoId == produtoId }
        )
        guard let item = try? context.fetch(descritor).first else { return }
        if quantidade <= 0 {
            context.delete(item)
        } else {
            item.quantidade = quantidade
        }
        try? context.save()
    }

    func remover(produtoId: UUID) {
        let descritor = FetchDescriptor<CartItem>(
            predicate: #Predicate { $0.produtoId == produtoId }
        )
        if let item = try? context.fetch(descritor).first {
            context.delete(item)
            try? context.save()
        }
    }

    func limpar() {
        for item in itens() {
            context.delete(item)
        }
        try? context.save()
    }

    func totalDeItens() -> Int {
        itens().reduce(0) { $0 + $1.quantidade }
    }
}
