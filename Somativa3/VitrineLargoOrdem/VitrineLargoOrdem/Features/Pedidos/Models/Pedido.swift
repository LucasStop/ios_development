import Foundation
import SwiftData

/// Status do pedido — timeline visual reflete o estágio atual.
enum StatusPedido: String, Codable, CaseIterable, Identifiable {
    case recebido
    case emProducao
    case despachado
    case entregue
    case cancelado

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .recebido: return "Recebido"
        case .emProducao: return "Em produção"
        case .despachado: return "A caminho"
        case .entregue: return "Entregue"
        case .cancelado: return "Cancelado"
        }
    }

    var simbolo: String {
        switch self {
        case .recebido: return "doc.text.fill"
        case .emProducao: return "hammer.fill"
        case .despachado: return "shippingbox.fill"
        case .entregue: return "checkmark.seal.fill"
        case .cancelado: return "xmark.octagon.fill"
        }
    }

    var ehFinal: Bool { self == .entregue || self == .cancelado }

    /// Etapas em ordem para a timeline (exclui cancelado).
    static let etapas: [StatusPedido] = [.recebido, .emProducao, .despachado, .entregue]

    var indiceNaTimeline: Int? {
        Self.etapas.firstIndex(of: self)
    }
}

/// Forma de pagamento escolhida no checkout — mock no MVP.
enum FormaPagamento: String, Codable, CaseIterable, Identifiable {
    case pix
    case cartaoCredito
    case cartaoDebito
    case boleto

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .pix: return "Pix"
        case .cartaoCredito: return "Cartão de crédito"
        case .cartaoDebito: return "Cartão de débito"
        case .boleto: return "Boleto"
        }
    }

    var simbolo: String {
        switch self {
        case .pix: return "qrcode"
        case .cartaoCredito: return "creditcard.fill"
        case .cartaoDebito: return "creditcard"
        case .boleto: return "barcode"
        }
    }
}

/// Pedido confirmado no checkout. SwiftData hoje, Postgres em V1.
@Model
final class Pedido {
    @Attribute(.unique) var id: UUID
    var numero: String                // Ex: VLO-AB12CD
    var usuarioId: UUID
    var statusRaw: String
    var formaPagamentoRaw: String
    var subtotal: Double
    var frete: Double
    var total: Double
    var enderecoLinha1: String         // Congelado no momento da compra.
    var enderecoLinha2: String
    var criadoEm: Date
    var atualizadoEm: Date

    @Relationship(deleteRule: .cascade, inverse: \ItemPedido.pedido)
    var itens: [ItemPedido] = []

    init(
        id: UUID = UUID(),
        numero: String,
        usuarioId: UUID,
        status: StatusPedido = .recebido,
        formaPagamento: FormaPagamento,
        subtotal: Double,
        frete: Double,
        total: Double,
        enderecoLinha1: String,
        enderecoLinha2: String,
        criadoEm: Date = .now,
        atualizadoEm: Date = .now,
        itens: [ItemPedido] = []
    ) {
        self.id = id
        self.numero = numero
        self.usuarioId = usuarioId
        self.statusRaw = status.rawValue
        self.formaPagamentoRaw = formaPagamento.rawValue
        self.subtotal = subtotal
        self.frete = frete
        self.total = total
        self.enderecoLinha1 = enderecoLinha1
        self.enderecoLinha2 = enderecoLinha2
        self.criadoEm = criadoEm
        self.atualizadoEm = atualizadoEm
        self.itens = itens
    }

    var status: StatusPedido {
        get { StatusPedido(rawValue: statusRaw) ?? .recebido }
        set { statusRaw = newValue.rawValue }
    }

    var formaPagamento: FormaPagamento {
        get { FormaPagamento(rawValue: formaPagamentoRaw) ?? .pix }
        set { formaPagamentoRaw = newValue.rawValue }
    }

    var totalFormatado: String { PrecoFormatter.formatado(total) }
    var totalAcessivel: String { PrecoFormatter.acessivel(total) }
    var subtotalFormatado: String { PrecoFormatter.formatado(subtotal) }
    var freteFormatado: String { PrecoFormatter.formatado(frete) }
    var quantidadeTotal: Int { itens.reduce(0) { $0 + $1.quantidade } }

    /// Gera um número curto e legível para o pedido (8 caracteres em base36).
    static func gerarNumero(de uuid: UUID = UUID()) -> String {
        let hex = uuid.uuidString.replacingOccurrences(of: "-", with: "")
        let trecho = String(hex.prefix(6)).uppercased()
        return "VLO-\(trecho)"
    }
}

/// Linha do pedido com os dados do produto congelados.
@Model
final class ItemPedido {
    @Attribute(.unique) var id: UUID
    var produtoId: UUID
    var nome: String
    var imagemNome: String
    var precoUnitario: Double
    var quantidade: Int

    var pedido: Pedido?

    init(
        id: UUID = UUID(),
        produtoId: UUID,
        nome: String,
        imagemNome: String,
        precoUnitario: Double,
        quantidade: Int,
        pedido: Pedido? = nil
    ) {
        self.id = id
        self.produtoId = produtoId
        self.nome = nome
        self.imagemNome = imagemNome
        self.precoUnitario = precoUnitario
        self.quantidade = quantidade
        self.pedido = pedido
    }

    var subtotal: Double { precoUnitario * Double(quantidade) }
    var subtotalFormatado: String { PrecoFormatter.formatado(subtotal) }
    var subtotalAcessivel: String { PrecoFormatter.acessivel(subtotal) }
}
