import Foundation
import Combine
import SwiftData

/// Coordena a tela de vitrine: lista produtos, aplica busca, alterna favoritos.
///
/// Recebe Repositories via DI (ADR-0001 decisão 3 — MVVM leve com Repository).
/// Não conhece SwiftData diretamente; apenas o contrato dos repositories.
@MainActor
final class VitrineViewModel: ObservableObject {

    @Published var termoBusca: String = ""
    @Published private(set) var produtos: [Produto] = []
    @Published private(set) var idsFavoritados: Set<UUID> = []

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

    var produtosFiltrados: [Produto] {
        let termo = termoBusca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termo.isEmpty else { return produtos }
        return produtos.filter {
            $0.nome.localizedCaseInsensitiveContains(termo) ||
            $0.categoria.localizedCaseInsensitiveContains(termo)
        }
    }

    func recarregar() {
        produtos = (try? productRepository.todos()) ?? []
        idsFavoritados = favoriteRepository.todos()
    }

    func produto(comId id: UUID) -> Produto? {
        productRepository.produto(comId: id)
    }

    func isFavorito(_ produto: Produto) -> Bool {
        idsFavoritados.contains(produto.id)
    }

    func alternarFavorito(do produto: Produto) {
        favoriteRepository.alternar(produtoId: produto.id)
        idsFavoritados = favoriteRepository.todos()
    }
}
