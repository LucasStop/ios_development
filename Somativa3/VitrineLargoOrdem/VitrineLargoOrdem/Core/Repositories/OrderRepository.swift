import Foundation
import SwiftData

/// Contrato para CRUD de pedidos. Implementação local hoje;
/// quando V1 trouxer Supabase, troca por SupabaseOrderRepository.
@MainActor
protocol OrderRepository: AnyObject {
    func listar(usuarioId: UUID) -> [Pedido]
    func pedido(comId id: UUID) -> Pedido?
    func criar(_ pedido: Pedido)
    func atualizarStatus(pedidoId: UUID, novo: StatusPedido)
}

@MainActor
final class LocalOrderRepository: OrderRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func listar(usuarioId: UUID) -> [Pedido] {
        let descritor = FetchDescriptor<Pedido>(
            predicate: #Predicate { $0.usuarioId == usuarioId },
            sortBy: [SortDescriptor(\.criadoEm, order: .reverse)]
        )
        return (try? context.fetch(descritor)) ?? []
    }

    func pedido(comId id: UUID) -> Pedido? {
        let descritor = FetchDescriptor<Pedido>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descritor).first
    }

    func criar(_ pedido: Pedido) {
        context.insert(pedido)
        try? context.save()
    }

    func atualizarStatus(pedidoId: UUID, novo: StatusPedido) {
        guard let pedido = pedido(comId: pedidoId) else { return }
        pedido.status = novo
        pedido.atualizadoEm = .now
        try? context.save()
    }
}
