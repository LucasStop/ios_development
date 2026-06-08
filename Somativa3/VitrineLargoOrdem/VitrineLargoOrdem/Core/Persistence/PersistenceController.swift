import Foundation
import SwiftData

/// Configuração e composição raiz do SwiftData.
///
/// Responsável por criar o `ModelContainer` único da app, registrar
/// todas as entidades (`@Model`) e executar o seed inicial quando o
/// banco estiver vazio.
///
/// A escolha do SwiftData está registrada no ADR-0001 decisão 2 —
/// se for substituído por Core Data, esta é a fronteira a refatorar.
@MainActor
enum PersistenceController {

    /// Container compartilhado da aplicação (persistente em disco).
    static let shared: ModelContainer = {
        let container = makeContainer(inMemory: false)
        seedIfNeeded(in: container.mainContext)
        return container
    }()

    /// Container in-memory para previews e testes — não persiste entre execuções.
    static let preview: ModelContainer = {
        let container = makeContainer(inMemory: true)
        seedIfNeeded(in: container.mainContext)
        return container
    }()

    private static func makeContainer(inMemory: Bool) -> ModelContainer {
        let schema = Schema([
            Produto.self,
            FavoriteItem.self,
            CartItem.self,
            Usuario.self,
            CredencialUsuario.self,
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Falha ao inicializar ModelContainer: \(error)")
        }
    }

    /// Insere os produtos do seed se o banco estiver vazio.
    /// Idempotente: roda em todo boot mas só faz trabalho na primeira vez.
    private static func seedIfNeeded(in context: ModelContext) {
        let descritor = FetchDescriptor<Produto>()
        let total = (try? context.fetchCount(descritor)) ?? 0
        guard total == 0 else { return }

        for seed in ProdutoSeedData.produtos {
            context.insert(seed.toProduto())
        }
        try? context.save()
    }
}
