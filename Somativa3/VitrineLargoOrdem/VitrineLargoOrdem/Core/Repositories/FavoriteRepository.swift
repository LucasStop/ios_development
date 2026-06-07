import Foundation
import SwiftData

/// Contrato para gerenciamento de favoritos.
///
/// Em V1 (com auth) a coleção passa a ser por `userId`; o protocolo
/// não muda, apenas a implementação.
@MainActor
protocol FavoriteRepository: AnyObject {
    /// Verifica se um produto está marcado como favorito.
    func isFavorito(produtoId: UUID) -> Bool

    /// Alterna o estado de favorito do produto.
    func alternar(produtoId: UUID)

    /// Lista todos os IDs de produtos favoritados.
    func todos() -> Set<UUID>
}

@MainActor
final class LocalFavoriteRepository: FavoriteRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func isFavorito(produtoId: UUID) -> Bool {
        let descritor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.produtoId == produtoId }
        )
        return ((try? context.fetchCount(descritor)) ?? 0) > 0
    }

    func alternar(produtoId: UUID) {
        let descritor = FetchDescriptor<FavoriteItem>(
            predicate: #Predicate { $0.produtoId == produtoId }
        )
        if let existente = try? context.fetch(descritor).first {
            context.delete(existente)
        } else {
            context.insert(FavoriteItem(produtoId: produtoId))
        }
        try? context.save()
    }

    func todos() -> Set<UUID> {
        let descritor = FetchDescriptor<FavoriteItem>()
        let itens = (try? context.fetch(descritor)) ?? []
        return Set(itens.map(\.produtoId))
    }
}
