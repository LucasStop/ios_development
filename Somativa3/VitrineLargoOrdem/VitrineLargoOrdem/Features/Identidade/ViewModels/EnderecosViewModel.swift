import Foundation
import Combine

/// Lista de endereços do usuário atual.
@MainActor
final class EnderecosViewModel: ObservableObject {

    @Published private(set) var enderecos: [Endereco] = []

    private let repository: AddressRepository
    private let usuarioId: UUID

    init(repository: AddressRepository, usuarioId: UUID) {
        self.repository = repository
        self.usuarioId = usuarioId
        recarregar()
    }

    var estaVazio: Bool { enderecos.isEmpty }
    var total: Int { enderecos.count }

    func recarregar() {
        enderecos = repository.listar(usuarioId: usuarioId)
    }

    func remover(_ endereco: Endereco) {
        repository.remover(endereco)
        recarregar()
    }

    func definirComoPadrao(_ endereco: Endereco) {
        repository.definirComoPadrao(endereco)
        recarregar()
    }
}
