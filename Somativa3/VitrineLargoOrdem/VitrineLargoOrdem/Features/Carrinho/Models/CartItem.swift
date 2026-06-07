import Foundation
import SwiftData

/// Item adicionado ao carrinho do usuário.
///
/// Armazena o `produtoId`, `quantidade` e preço congelado no momento da adição
/// para não perder o valor caso o catálogo mude. Separação de Produto evita
/// duplicação do modelo do catálogo dentro do carrinho.
@Model
final class CartItem {
    @Attribute(.unique) var produtoId: UUID
    var nome: String
    var imagemNome: String
    var precoUnitario: Double
    var quantidade: Int
    var adicionadoEm: Date

    init(
        produtoId: UUID,
        nome: String,
        imagemNome: String,
        precoUnitario: Double,
        quantidade: Int = 1,
        adicionadoEm: Date = .now
    ) {
        self.produtoId = produtoId
        self.nome = nome
        self.imagemNome = imagemNome
        self.precoUnitario = precoUnitario
        self.quantidade = quantidade
        self.adicionadoEm = adicionadoEm
    }

    var subtotal: Double { precoUnitario * Double(quantidade) }
}
