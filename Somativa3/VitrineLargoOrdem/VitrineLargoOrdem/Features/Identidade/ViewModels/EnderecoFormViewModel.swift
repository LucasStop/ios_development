import Foundation
import Combine

/// Estado e regras do formulário de endereço — usado tanto para
/// adicionar quanto editar. Encapsula a busca por CEP via ViaCEP
/// e a validação dos campos obrigatórios.
@MainActor
final class EnderecoFormViewModel: ObservableObject {

    // Campos
    @Published var apelido: String = "Casa"
    @Published var cep: String = ""
    @Published var logradouro: String = ""
    @Published var numero: String = ""
    @Published var complemento: String = ""
    @Published var bairro: String = ""
    @Published var cidade: String = ""
    @Published var uf: String = ""
    @Published var ehPadrao: Bool = false

    // Estado
    @Published private(set) var buscandoCEP: Bool = false
    @Published var erro: CEPError?
    @Published var mensagem: String?

    private let cepService: CEPService
    private let addressRepository: AddressRepository
    private let usuarioId: UUID

    private(set) var enderecoExistente: Endereco?

    init(
        cepService: CEPService,
        addressRepository: AddressRepository,
        usuarioId: UUID,
        editando: Endereco? = nil
    ) {
        self.cepService = cepService
        self.addressRepository = addressRepository
        self.usuarioId = usuarioId
        self.enderecoExistente = editando

        if let endereco = editando {
            self.apelido = endereco.apelido
            self.cep = endereco.cep
            self.logradouro = endereco.logradouro
            self.numero = endereco.numero
            self.complemento = endereco.complemento
            self.bairro = endereco.bairro
            self.cidade = endereco.cidade
            self.uf = endereco.uf
            self.ehPadrao = endereco.ehPadrao
        }
    }

    var modo: String { enderecoExistente == nil ? "Novo endereço" : "Editar endereço" }

    var formularioValido: Bool {
        !apelido.trimmingCharacters(in: .whitespaces).isEmpty
        && cep.filter { $0.isNumber }.count == 8
        && !logradouro.trimmingCharacters(in: .whitespaces).isEmpty
        && !numero.trimmingCharacters(in: .whitespaces).isEmpty
        && !bairro.trimmingCharacters(in: .whitespaces).isEmpty
        && !cidade.trimmingCharacters(in: .whitespaces).isEmpty
        && uf.count == 2
    }

    var cepFormatadoExibicao: String {
        Endereco.formatarCEP(cep)
    }

    /// Aciona ViaCEP. Atualiza apenas campos vazios (preserva o que o
    /// usuário já tenha digitado).
    func buscarCEP() async {
        erro = nil
        buscandoCEP = true
        defer { buscandoCEP = false }

        do {
            let resultado = try await cepService.buscar(cep: cep)
            if logradouro.isEmpty { logradouro = resultado.logradouro }
            if bairro.isEmpty { bairro = resultado.bairro }
            if cidade.isEmpty { cidade = resultado.cidade }
            if uf.isEmpty { uf = resultado.uf }
            cep = resultado.cep
        } catch let cepError as CEPError {
            erro = cepError
        } catch {
            erro = .redeIndisponivel
        }
    }

    func salvar() {
        let limpo: (String) -> String = { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if let endereco = enderecoExistente {
            endereco.apelido = limpo(apelido)
            endereco.cep = cep.filter { $0.isNumber }
            endereco.logradouro = limpo(logradouro)
            endereco.numero = limpo(numero)
            endereco.complemento = limpo(complemento)
            endereco.bairro = limpo(bairro)
            endereco.cidade = limpo(cidade)
            endereco.uf = uf.uppercased()
            endereco.ehPadrao = ehPadrao
            addressRepository.salvar(endereco)
        } else {
            let novo = Endereco(
                apelido: limpo(apelido),
                cep: cep.filter { $0.isNumber },
                logradouro: limpo(logradouro),
                numero: limpo(numero),
                complemento: limpo(complemento),
                bairro: limpo(bairro),
                cidade: limpo(cidade),
                uf: uf.uppercased(),
                ehPadrao: ehPadrao,
                usuarioId: usuarioId
            )
            addressRepository.salvar(novo)
        }

        mensagem = enderecoExistente == nil ? "Endereço cadastrado." : "Endereço atualizado."
    }
}
