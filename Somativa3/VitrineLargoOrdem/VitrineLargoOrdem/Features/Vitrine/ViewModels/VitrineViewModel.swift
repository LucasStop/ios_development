import Foundation
import Combine

@MainActor
final class VitrineViewModel: ObservableObject {

    @Published private(set) var produtos: [ProdutoArtesanal]
    @Published var termoBusca: String = ""

    init(produtos: [ProdutoArtesanal] = ProdutosMockData.todos) {
        self.produtos = produtos
    }

    var produtosFiltrados: [ProdutoArtesanal] {
        let termo = termoBusca.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !termo.isEmpty else { return produtos }
        return produtos.filter {
            $0.nome.localizedCaseInsensitiveContains(termo) ||
            $0.categoria.localizedCaseInsensitiveContains(termo)
        }
    }

    func alternarFavorito(do produto: ProdutoArtesanal) {
        guard let indice = produtos.firstIndex(where: { $0.id == produto.id }) else { return }
        produtos[indice].isFavorito.toggle()
    }

    func produto(comId id: UUID) -> ProdutoArtesanal? {
        produtos.first(where: { $0.id == id })
    }
}
