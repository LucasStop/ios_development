import Foundation
@testable import VitrineLargoOrdem

/// Implementação em memória do `ProductRepository` para testes — sem SwiftData.
@MainActor
final class MockProductRepository: ProductRepository {

    var produtos: [Produto]
    var todosFoiChamado: Int = 0

    init(produtos: [Produto] = []) {
        self.produtos = produtos
    }

    func todos() throws -> [Produto] {
        todosFoiChamado += 1
        return produtos
    }

    func produto(comId id: UUID) -> Produto? {
        produtos.first { $0.id == id }
    }

    func buscar(termo: String) throws -> [Produto] {
        let termoLimpo = termo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termoLimpo.isEmpty else { return produtos }
        return produtos.filter {
            $0.nome.localizedCaseInsensitiveContains(termoLimpo) ||
            $0.categoria.localizedCaseInsensitiveContains(termoLimpo)
        }
    }
}

/// Implementação em memória do `FavoriteRepository` para testes.
@MainActor
final class MockFavoriteRepository: FavoriteRepository {

    var favoritos: Set<UUID> = []
    var alternarChamadoCom: [UUID] = []

    func isFavorito(produtoId: UUID) -> Bool {
        favoritos.contains(produtoId)
    }

    func alternar(produtoId: UUID) {
        alternarChamadoCom.append(produtoId)
        if favoritos.contains(produtoId) {
            favoritos.remove(produtoId)
        } else {
            favoritos.insert(produtoId)
        }
    }

    func todos() -> Set<UUID> {
        favoritos
    }
}

/// Implementação em memória do `CartRepository` para testes.
@MainActor
final class MockCartRepository: CartRepository {

    var items: [CartItem] = []

    func itens() -> [CartItem] {
        items.sorted { $0.adicionadoEm < $1.adicionadoEm }
    }

    func adicionar(produto: Produto, quantidade: Int) {
        if let existente = items.first(where: { $0.produtoId == produto.id }) {
            existente.quantidade += quantidade
        } else {
            items.append(CartItem(
                produtoId: produto.id,
                nome: produto.nome,
                imagemNome: produto.imagemNome,
                precoUnitario: produto.preco,
                quantidade: quantidade
            ))
        }
    }

    func atualizar(produtoId: UUID, quantidade: Int) {
        guard let item = items.first(where: { $0.produtoId == produtoId }) else { return }
        if quantidade <= 0 {
            items.removeAll { $0.produtoId == produtoId }
        } else {
            item.quantidade = quantidade
        }
    }

    func remover(produtoId: UUID) {
        items.removeAll { $0.produtoId == produtoId }
    }

    func limpar() {
        items.removeAll()
    }

    func totalDeItens() -> Int {
        items.reduce(0) { $0 + $1.quantidade }
    }
}

/// Fixtures de Produto reutilizadas em vários testes.
enum ProdutoFixture {
    static let capivara = Produto(
        id: UUID(uuidString: "11111111-1111-1111-1111-000000000001")!,
        nome: "Escultura de Capivara",
        artesao: "Sebastião Andrade",
        preco: 85.00,
        categoria: "Madeira",
        imagemNome: "leaf.fill",
        descricao: "Capivara entalhada à mão",
        estoque: 5
    )
    static let quibe = Produto(
        id: UUID(uuidString: "11111111-1111-1111-1111-000000000002")!,
        nome: "Quibe Frito",
        artesao: "Família Saadi",
        preco: 12.00,
        categoria: "Comidas",
        imagemNome: "fork.knife",
        descricao: "Quibe libanês frito na hora",
        estoque: 50
    )
    static let cuia = Produto(
        id: UUID(uuidString: "11111111-1111-1111-1111-000000000006")!,
        nome: "Cuia de Mate",
        artesao: "Pedro Kovalski",
        preco: 45.00,
        categoria: "Madeira",
        imagemNome: "cup.and.saucer.fill",
        descricao: "Cuia de porongo natural",
        estoque: 8
    )

    static let exemplos: [Produto] = [capivara, quibe, cuia]
}
