import Foundation
import SwiftData

/// Contrato para acesso ao catálogo de produtos.
///
/// Abstrai a fonte de dados (SwiftData local hoje, Supabase amanhã).
/// Permite que Views e ViewModels não saibam de onde os produtos vêm.
@MainActor
protocol ProductRepository: AnyObject {
    /// Retorna todos os produtos disponíveis no catálogo.
    func todos() throws -> [Produto]

    /// Busca um produto específico por id.
    func produto(comId id: UUID) -> Produto?

    /// Filtra produtos por termo (case-insensitive) em nome ou categoria.
    func buscar(termo: String) throws -> [Produto]
}

// MARK: - Implementação SwiftData

/// Implementação local baseada em SwiftData. Fonte de verdade até V1.
@MainActor
final class LocalProductRepository: ProductRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func todos() throws -> [Produto] {
        let descritor = FetchDescriptor<Produto>(
            sortBy: [SortDescriptor(\.criadoEm, order: .forward)]
        )
        return try context.fetch(descritor)
    }

    func produto(comId id: UUID) -> Produto? {
        let descritor = FetchDescriptor<Produto>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descritor).first
    }

    func buscar(termo: String) throws -> [Produto] {
        let termoLimpo = termo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termoLimpo.isEmpty else { return try todos() }

        // SwiftData ainda não suporta localizedCaseInsensitiveContains em #Predicate,
        // então buscamos tudo e filtramos em memória — adequado para um catálogo
        // de 12 itens; quando passar de centenas, migrar para SQL full-text search.
        return try todos().filter {
            $0.nome.localizedCaseInsensitiveContains(termoLimpo) ||
            $0.categoria.localizedCaseInsensitiveContains(termoLimpo)
        }
    }
}
