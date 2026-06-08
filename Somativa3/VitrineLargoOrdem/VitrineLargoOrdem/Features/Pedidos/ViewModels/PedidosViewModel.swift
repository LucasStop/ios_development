import Foundation
import Combine

/// Lista os pedidos do usuário, ordenados do mais recente ao mais
/// antigo. Em paralelo simula a progressão de status com timers
/// locais para dar vida à demo (recebido → em produção → despachado
/// → entregue).
@MainActor
final class PedidosViewModel: ObservableObject {

    @Published private(set) var pedidos: [Pedido] = []

    private let orderRepository: OrderRepository
    private let usuarioId: UUID
    private var simulationTask: Task<Void, Never>?

    init(orderRepository: OrderRepository, usuarioId: UUID) {
        self.orderRepository = orderRepository
        self.usuarioId = usuarioId
        recarregar()
    }

    deinit {
        simulationTask?.cancel()
    }

    var estaVazio: Bool { pedidos.isEmpty }
    var total: Int { pedidos.count }

    func recarregar() {
        pedidos = orderRepository.listar(usuarioId: usuarioId)
        agendarSimulacaoStatus()
    }

    /// Avança o status do pedido para o próximo estágio (manual,
    /// usado por botão na tela de detalhes — útil para a demo).
    func avancarStatus(do pedido: Pedido) {
        guard let indice = pedido.status.indiceNaTimeline,
              indice < StatusPedido.etapas.count - 1 else { return }
        let proximo = StatusPedido.etapas[indice + 1]
        orderRepository.atualizarStatus(pedidoId: pedido.id, novo: proximo)
        recarregar()
    }

    func cancelar(_ pedido: Pedido) {
        orderRepository.atualizarStatus(pedidoId: pedido.id, novo: .cancelado)
        recarregar()
    }

    // MARK: - Simulação local de progresso

    /// Para cada pedido não-final, avança 1 etapa a cada ~12s.
    /// Cancela e reinicia a cada recarregar() para refletir mudanças.
    private func agendarSimulacaoStatus() {
        simulationTask?.cancel()
        simulationTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 12_000_000_000)
                if Task.isCancelled { return }
                self?.passoSimulacao()
            }
        }
    }

    private func passoSimulacao() {
        var alterou = false
        for pedido in pedidos where !pedido.status.ehFinal {
            if let indice = pedido.status.indiceNaTimeline,
               indice < StatusPedido.etapas.count - 1 {
                let proximo = StatusPedido.etapas[indice + 1]
                orderRepository.atualizarStatus(pedidoId: pedido.id, novo: proximo)
                alterou = true
            }
        }
        if alterou { pedidos = orderRepository.listar(usuarioId: usuarioId) }
    }
}
