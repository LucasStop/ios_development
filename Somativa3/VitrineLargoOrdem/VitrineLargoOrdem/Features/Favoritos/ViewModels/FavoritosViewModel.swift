import Foundation
import Combine

/// Lista os produtos favoritados pelo usuário.
@MainActor
final class FavoritosViewModel: ObservableObject {

    @Published private(set) var favoritos: [Produto] = []

    private let productRepository: ProductRepository
    private let favoriteRepository: FavoriteRepository

    init(
        productRepository: ProductRepository,
        favoriteRepository: FavoriteRepository
    ) {
        self.productRepository = productRepository
        self.favoriteRepository = favoriteRepository
        recarregar()
    }

    var estaVazio: Bool { favoritos.isEmpty }
    var total: Int { favoritos.count }

    func recarregar() {
        let ids = favoriteRepository.todos()
        let todosProdutos = (try? productRepository.todos()) ?? []
        favoritos = todosProdutos.filter { ids.contains($0.id) }
    }

    func remover(produto: Produto) {
        favoriteRepository.alternar(produtoId: produto.id)
        recarregar()
    }
}
