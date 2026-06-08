import Foundation

/// Resposta crua da API ViaCEP. Mapeada para `EnderecoViaCEP` interno
/// para evitar vazar nomenclatura externa para as Views.
private struct ViaCEPResponse: Decodable {
    let cep: String?
    let logradouro: String?
    let bairro: String?
    let localidade: String?
    let uf: String?
    let erro: Bool?
}

/// Endereço retornado pela busca via CEP — campos só com os dados
/// que a API garante.
struct EnderecoViaCEP: Equatable {
    let cep: String
    let logradouro: String
    let bairro: String
    let cidade: String
    let uf: String
}

/// Erros de busca de CEP.
enum CEPError: LocalizedError, Equatable {
    case cepInvalido
    case cepNaoEncontrado
    case redeIndisponivel

    var errorDescription: String? {
        switch self {
        case .cepInvalido: return "Informe um CEP válido com 8 dígitos."
        case .cepNaoEncontrado: return "Não encontramos endereço para este CEP."
        case .redeIndisponivel: return "Falha ao consultar o CEP. Verifique sua conexão."
        }
    }
}

/// Cliente do serviço público ViaCEP (https://viacep.com.br/).
/// API gratuita, sem necessidade de token, com rate limit generoso
/// para uso de e-commerce real.
protocol CEPService: Sendable {
    func buscar(cep: String) async throws -> EnderecoViaCEP
}

final class ViaCEPService: CEPService {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func buscar(cep: String) async throws -> EnderecoViaCEP {
        let apenasDigitos = cep.filter { $0.isNumber }
        guard apenasDigitos.count == 8,
              let url = URL(string: "https://viacep.com.br/ws/\(apenasDigitos)/json/")
        else { throw CEPError.cepInvalido }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw CEPError.redeIndisponivel
        }

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw CEPError.redeIndisponivel
        }

        let decoded: ViaCEPResponse
        do {
            decoded = try JSONDecoder().decode(ViaCEPResponse.self, from: data)
        } catch {
            throw CEPError.redeIndisponivel
        }

        // A API retorna `{ "erro": true }` quando o CEP não existe.
        if decoded.erro == true {
            throw CEPError.cepNaoEncontrado
        }

        return EnderecoViaCEP(
            cep: decoded.cep?.filter { $0.isNumber } ?? apenasDigitos,
            logradouro: decoded.logradouro ?? "",
            bairro: decoded.bairro ?? "",
            cidade: decoded.localidade ?? "",
            uf: (decoded.uf ?? "").uppercased()
        )
    }
}

/// Implementação mock para testes — sem rede.
final class MockCEPService: CEPService {
    var resposta: Result<EnderecoViaCEP, CEPError> = .failure(.cepNaoEncontrado)
    var chamadasCom: [String] = []

    func buscar(cep: String) async throws -> EnderecoViaCEP {
        chamadasCom.append(cep)
        switch resposta {
        case .success(let endereco): return endereco
        case .failure(let erro): throw erro
        }
    }
}
