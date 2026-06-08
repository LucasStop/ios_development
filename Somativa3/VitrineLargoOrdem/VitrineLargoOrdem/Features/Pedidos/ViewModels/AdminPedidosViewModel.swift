import Foundation
import Combine
import SwiftData

/// Visão administrativa de todos os pedidos do sistema. Acessada
/// apenas por usuários com `role == admin`.
@MainActor
final class AdminPedidosViewModel: ObservableObject {

    @Published private(set) var pedidos: [Pedido] = []
    @Published var filtroStatus: StatusPedido? = nil
    @Published var termoBusca: String = ""

    private let context: ModelContext
    private let orderRepository: OrderRepository

    init(context: ModelContext, orderRepository: OrderRepository) {
        self.context = context
        self.orderRepository = orderRepository
        recarregar()
    }

    var estaVazio: Bool { pedidos.isEmpty }

    var pedidosFiltrados: [Pedido] {
        var resultado = pedidos
        if let filtroStatus {
            resultado = resultado.filter { $0.status == filtroStatus }
        }
        let termo = termoBusca.trimmingCharacters(in: .whitespacesAndNewlines)
        if !termo.isEmpty {
            resultado = resultado.filter {
                $0.numero.localizedCaseInsensitiveContains(termo)
            }
        }
        return resultado
    }

    /// Resumo por status para os chips de filtro.
    var contagemPorStatus: [(status: StatusPedido, total: Int)] {
        StatusPedido.allCases.map { status in
            (status, pedidos.filter { $0.status == status }.count)
        }
    }

    var totalPedidos: Int { pedidos.count }
    var totalFaturamento: Double {
        pedidos.filter { !$0.status.ehFinal || $0.status == .entregue }
            .reduce(0) { $0 + $1.total }
    }
    var totalFaturamentoFormatado: String { PrecoFormatter.formatado(totalFaturamento) }

    func recarregar() {
        // Lê todos os pedidos do banco (admin enxerga geral).
        let descritor = FetchDescriptor<Pedido>(
            sortBy: [SortDescriptor(\.criadoEm, order: .reverse)]
        )
        pedidos = (try? context.fetch(descritor)) ?? []
    }

    func avancarStatus(do pedido: Pedido) {
        guard let indice = pedido.status.indiceNaTimeline,
              indice < StatusPedido.etapas.count - 1 else { return }
        let proximo = StatusPedido.etapas[indice + 1]
        orderRepository.atualizarStatus(pedidoId: pedido.id, novo: proximo)
        recarregar()
    }

    func definirStatus(_ status: StatusPedido, para pedido: Pedido) {
        orderRepository.atualizarStatus(pedidoId: pedido.id, novo: status)
        recarregar()
    }

    func cancelar(_ pedido: Pedido) {
        orderRepository.atualizarStatus(pedidoId: pedido.id, novo: .cancelado)
        recarregar()
    }

    /// Procura o usuário dono do pedido para exibir nome/email no card.
    func donoDoPedido(_ pedido: Pedido) -> Usuario? {
        let usuarioId = pedido.usuarioId
        let descritor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.id == usuarioId })
        return try? context.fetch(descritor).first
    }
}
