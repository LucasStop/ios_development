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

    private static let precoFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()

    var precoFormatado: String {
        Self.precoFormatter.string(from: NSNumber(value: preco)) ?? "R$ \(preco)"
    }

    var precoAcessivel: String {
        let inteiro = Int(preco)
        let centavos = Int((preco - Double(inteiro)) * 100)
        if centavos == 0 {
            return "Preço: \(inteiro) reais"
        }
        return "Preço: \(inteiro) reais e \(centavos) centavos"
    }
}
