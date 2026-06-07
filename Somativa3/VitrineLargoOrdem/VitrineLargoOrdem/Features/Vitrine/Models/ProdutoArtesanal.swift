import Foundation

struct ProdutoArtesanal: Identifiable, Hashable {
    let id: UUID
    let nome: String
    let artesao: String
    let preco: Double
    let categoria: String
    let imagemNome: String
    let descricao: String
    var isFavorito: Bool

    init(
        id: UUID = UUID(),
        nome: String,
        artesao: String,
        preco: Double,
        categoria: String,
        imagemNome: String,
        descricao: String,
        isFavorito: Bool = false
    ) {
        self.id = id
        self.nome = nome
        self.artesao = artesao
        self.preco = preco
        self.categoria = categoria
        self.imagemNome = imagemNome
        self.descricao = descricao
        self.isFavorito = isFavorito
    }

    var precoFormatado: String {
        PrecoFormatter.formatado(preco)
    }

    var precoAcessivel: String {
        PrecoFormatter.acessivel(preco)
    }
}
