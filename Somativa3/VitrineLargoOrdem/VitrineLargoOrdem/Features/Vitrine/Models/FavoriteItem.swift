import Foundation
import SwiftData

/// Marca um produto como favorito do usuário atual.
///
/// Separado do `Produto` para deixar produto livre de estado de UI/usuário —
/// quando V1 introduzir auth, esta coleção passa a ser por `userId`.
@Model
final class FavoriteItem {
    @Attribute(.unique) var produtoId: UUID
    var adicionadoEm: Date

    init(produtoId: UUID, adicionadoEm: Date = .now) {
        self.produtoId = produtoId
        self.adicionadoEm = adicionadoEm
    }
}
