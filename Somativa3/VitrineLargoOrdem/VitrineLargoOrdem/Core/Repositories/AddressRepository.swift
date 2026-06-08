import Foundation
import SwiftData

/// Contrato para CRUD de endereços do usuário atual.
@MainActor
protocol AddressRepository: AnyObject {
    func listar(usuarioId: UUID) -> [Endereco]
    func enderecoPadrao(usuarioId: UUID) -> Endereco?
    func salvar(_ endereco: Endereco)
    func remover(_ endereco: Endereco)
    func definirComoPadrao(_ endereco: Endereco)
}

@MainActor
final class LocalAddressRepository: AddressRepository {

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func listar(usuarioId: UUID) -> [Endereco] {
        let descritor = FetchDescriptor<Endereco>(
            predicate: #Predicate { $0.usuarioId == usuarioId },
            sortBy: [SortDescriptor(\.criadoEm, order: .forward)]
        )
        let lista = (try? context.fetch(descritor)) ?? []
        // SwiftData SortDescriptor não aceita Bool — fazemos o pin do
        // endereço padrão no topo em memória.
        return lista.sorted { lhs, rhs in
            if lhs.ehPadrao == rhs.ehPadrao { return lhs.criadoEm < rhs.criadoEm }
            return lhs.ehPadrao && !rhs.ehPadrao
        }
    }

    func enderecoPadrao(usuarioId: UUID) -> Endereco? {
        let descritor = FetchDescriptor<Endereco>(
            predicate: #Predicate { $0.usuarioId == usuarioId && $0.ehPadrao }
        )
        return try? context.fetch(descritor).first
    }

    func salvar(_ endereco: Endereco) {
        // Se for o primeiro endereço do usuário, vira padrão automaticamente.
        let existentes = listar(usuarioId: endereco.usuarioId)
        if existentes.isEmpty { endereco.ehPadrao = true }

        // Se foi marcado como padrão e já há outro, desmarca os antigos.
        if endereco.ehPadrao {
            for outro in existentes where outro.id != endereco.id {
                outro.ehPadrao = false
            }
        }

        // Persistência (insert se for novo, update se já existir)
        if existentes.contains(where: { $0.id == endereco.id }) == false {
            context.insert(endereco)
        }
        try? context.save()
    }

    func remover(_ endereco: Endereco) {
        let usuarioId = endereco.usuarioId
        let eraPadrao = endereco.ehPadrao
        context.delete(endereco)
        try? context.save()

        // Se removemos o padrão, promove o mais antigo restante a padrão.
        if eraPadrao, let proximo = listar(usuarioId: usuarioId).first {
            proximo.ehPadrao = true
            try? context.save()
        }
    }

    func definirComoPadrao(_ endereco: Endereco) {
        let existentes = listar(usuarioId: endereco.usuarioId)
        for outro in existentes { outro.ehPadrao = (outro.id == endereco.id) }
        try? context.save()
    }
}
