import Foundation
import Combine

/// Etapas do checkout, na ordem em que aparecem.
enum CheckoutEtapa: Int, CaseIterable, Identifiable {
    case endereco = 0
    case pagamento
    case revisao
    case confirmacao

    var id: Int { rawValue }

    var titulo: String {
        switch self {
        case .endereco: return "Entrega"
        case .pagamento: return "Pagamento"
        case .revisao: return "Revisão"
        case .confirmacao: return "Confirmação"
        }
    }

    var simbolo: String {
        switch self {
        case .endereco: return "house.fill"
        case .pagamento: return "creditcard.fill"
        case .revisao: return "checklist"
        case .confirmacao: return "checkmark.seal.fill"
        }
    }
}

/// Estado do fluxo de checkout em 4 etapas. Persiste o pedido ao
/// concluir e limpa o carrinho.
@MainActor
final class CheckoutViewModel: ObservableObject {

    @Published var etapaAtual: CheckoutEtapa = .endereco
    @Published var enderecoSelecionado: Endereco?
    @Published var formaPagamento: FormaPagamento = .pix
    @Published var aceitouTermos: Bool = false
    @Published var processando: Bool = false
    @Published private(set) var pedidoCriado: Pedido?

    private let carrinhoViewModel: CarrinhoViewModel
    private let addressRepository: AddressRepository
    private let orderRepository: OrderRepository
    private let usuarioId: UUID

    init(
        carrinhoViewModel: CarrinhoViewModel,
        addressRepository: AddressRepository,
        orderRepository: OrderRepository,
        usuarioId: UUID
    ) {
        self.carrinhoViewModel = carrinhoViewModel
        self.addressRepository = addressRepository
        self.orderRepository = orderRepository
        self.usuarioId = usuarioId
        self.enderecoSelecionado = addressRepository.enderecoPadrao(usuarioId: usuarioId)
    }

    var enderecosDisponiveis: [Endereco] {
        addressRepository.listar(usuarioId: usuarioId)
    }

    var podeAvancar: Bool {
        switch etapaAtual {
        case .endereco: return enderecoSelecionado != nil
        case .pagamento: return true
        case .revisao: return aceitouTermos
        case .confirmacao: return false
        }
    }

    var podeVoltar: Bool {
        etapaAtual != .endereco && etapaAtual != .confirmacao
    }

    var indiceEtapa: Int { etapaAtual.rawValue }
    var totalEtapas: Int { CheckoutEtapa.allCases.count - 1 } // exclui confirmação visualmente

    func avancar() {
        guard podeAvancar else { return }
        switch etapaAtual {
        case .endereco: etapaAtual = .pagamento
        case .pagamento: etapaAtual = .revisao
        case .revisao: finalizar()
        case .confirmacao: break
        }
    }

    func voltar() {
        guard podeVoltar else { return }
        switch etapaAtual {
        case .pagamento: etapaAtual = .endereco
        case .revisao: etapaAtual = .pagamento
        default: break
        }
    }

    private func finalizar() {
        guard let endereco = enderecoSelecionado else { return }
        processando = true

        // Simula latência de gateway de pagamento.
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 800_000_000)

            let itens = carrinhoViewModel.itens.map { item in
                ItemPedido(
                    produtoId: item.produtoId,
                    nome: item.nome,
                    imagemNome: item.imagemNome,
                    precoUnitario: item.precoUnitario,
                    quantidade: item.quantidade
                )
            }

            let pedido = Pedido(
                numero: Pedido.gerarNumero(),
                usuarioId: usuarioId,
                status: .recebido,
                formaPagamento: formaPagamento,
                subtotal: carrinhoViewModel.subtotal,
                frete: carrinhoViewModel.freteFixo,
                total: carrinhoViewModel.total,
                enderecoLinha1: endereco.linhaPrincipal,
                enderecoLinha2: endereco.linhaSecundaria,
                itens: itens
            )

            orderRepository.criar(pedido)
            carrinhoViewModel.limpar()
            pedidoCriado = pedido
            processando = false
            etapaAtual = .confirmacao
        }
    }
}
