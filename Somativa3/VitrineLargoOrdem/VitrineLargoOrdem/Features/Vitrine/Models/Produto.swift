import Foundation
import SwiftData

/// Produto artesanal vendido na Feira do Largo da Ordem.
///
/// Migrado de struct para `@Model` SwiftData (ADR-0001 decisão 2) para
/// persistência local offline-first. Mantém a interface pública
/// (`precoFormatado`, `precoAcessivel`) usada pelas Views para evitar
/// migration em cascata.
///
/// Favoritos foram movidos para `FavoriteItem` em coleção separada
/// (ADR-0001 decisão 9 — separação de concerns; favoritos virarão
/// coleção do usuário quando houver auth na V1).
@Model
final class Produto {
    @Attribute(.unique) var id: UUID
    var nome: String
    var artesao: String
    var preco: Double
    var categoria: String
    var imagemNome: String
    var descricao: String
    var estoque: Int
    var criadoEm: Date

    init(
        id: UUID,
        nome: String,
        artesao: String,
        preco: Double,
        categoria: String,
        imagemNome: String,
        descricao: String,
        estoque: Int = 10,
        criadoEm: Date = .now
    ) {
        self.id = id
        self.nome = nome
        self.artesao = artesao
        self.preco = preco
        self.categoria = categoria
        self.imagemNome = imagemNome
        self.descricao = descricao
        self.estoque = estoque
        self.criadoEm = criadoEm
    }

    /// Preço formatado para exibição visual ("R$ 85,00").
    var precoFormatado: String { PrecoFormatter.formatado(preco) }

    /// Preço em texto natural para VoiceOver ("Preço: 85 reais").
    var precoAcessivel: String { PrecoFormatter.acessivel(preco) }

    /// Indica se ainda há disponibilidade para venda.
    var temEstoque: Bool { estoque > 0 }
}
