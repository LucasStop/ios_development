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
    @Published var categoriaSelecionada: String? = nil
    @Published private(set) var produtos: [Produto] = []
    @Published private(set) var idsFavoritados: Set<UUID> = []
    @Published private(set) var carregando: Bool = true

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

    /// Lista única, alfabética, de categorias presentes no catálogo atual.
    var categoriasDisponiveis: [String] {
        Array(Set(produtos.map(\.categoria))).sorted()
    }

    var produtosFiltrados: [Produto] {
        let termo = termoBusca.trimmingCharacters(in: .whitespacesAndNewlines)
        var resultado = produtos

        if let categoria = categoriaSelecionada {
            resultado = resultado.filter { $0.categoria == categoria }
        }

        if !termo.isEmpty {
            resultado = resultado.filter {
                $0.nome.localizedCaseInsensitiveContains(termo) ||
                $0.categoria.localizedCaseInsensitiveContains(termo)
            }
        }

        return resultado
    }

    func recarregar() {
        carregando = true
        produtos = (try? productRepository.todos()) ?? []
        idsFavoritados = favoriteRepository.todos()
        carregando = false
    }

    func limparFiltros() {
        categoriaSelecionada = nil
        termoBusca = ""
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
