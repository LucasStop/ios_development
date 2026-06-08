import Foundation

/// Wrapper minimalista do Supabase REST/Auth API.
///
/// Implementação propositalmente sem SDK externo:
/// - Mantém o projeto sem dependências SPM novas (CI sempre rápido).
/// - Cobre apenas o subset que usamos (signup/signin/me, REST com
///   filtros simples), suficiente para os fluxos da V1.
///
/// Quando precisarmos de realtime ou Storage avançado, podemos
/// migrar para `supabase-swift` mantendo a mesma fachada.
actor SupabaseClient {

    struct Configuracao {
        let url: URL
        let publishableKey: String
    }

    enum SupabaseError: LocalizedError {
        case requisicaoInvalida
        case servidor(status: Int, mensagem: String)
        case naoAutenticado
        case decodificacaoFalhou(Error)
        case rede(Error)

        var errorDescription: String? {
            switch self {
            case .requisicaoInvalida: return "Requisição inválida."
            case .servidor(let status, let msg):
                return "Erro do servidor (\(status)): \(msg)"
            case .naoAutenticado: return "Sessão expirada. Faça login novamente."
            case .decodificacaoFalhou(let erro): return "Não foi possível ler a resposta: \(erro.localizedDescription)"
            case .rede(let erro): return "Falha de rede: \(erro.localizedDescription)"
            }
        }
    }

    struct Sessao: Codable, Equatable {
        let accessToken: String
        let refreshToken: String
        let usuario: UsuarioRemoto

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case usuario = "user"
        }
    }

    struct UsuarioRemoto: Codable, Equatable {
        let id: String
        let email: String?
        let userMetadata: MetadadosUsuario?

        enum CodingKeys: String, CodingKey {
            case id, email
            case userMetadata = "user_metadata"
        }
    }

    struct MetadadosUsuario: Codable, Equatable {
        let nome: String?
    }

    private let configuracao: Configuracao
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private(set) var sessaoAtual: Sessao?

    init(configuracao: Configuracao, session: URLSession = .shared) {
        self.configuracao = configuracao
        self.session = session
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }

    func definirSessao(_ sessao: Sessao?) {
        self.sessaoAtual = sessao
    }

    // MARK: - Auth

    func cadastrar(email: String, senha: String, nome: String) async throws -> Sessao {
        struct Payload: Encodable {
            let email: String
            let password: String
            let data: [String: String]
        }
        let payload = Payload(email: email, password: senha, data: ["nome": nome])
        let sessao: Sessao = try await requisicao(
            metodo: "POST",
            caminho: "/auth/v1/signup",
            corpo: payload,
            autenticado: false
        )
        sessaoAtual = sessao
        return sessao
    }

    func entrar(email: String, senha: String) async throws -> Sessao {
        struct Payload: Encodable {
            let email: String
            let password: String
        }
        let payload = Payload(email: email, password: senha)
        let sessao: Sessao = try await requisicao(
            metodo: "POST",
            caminho: "/auth/v1/token?grant_type=password",
            corpo: payload,
            autenticado: false
        )
        sessaoAtual = sessao
        return sessao
    }

    func encerrarSessao() async {
        // O endpoint /logout existe mas não é crítico — limpamos só
        // localmente para evitar bloqueio caso a rede esteja off.
        sessaoAtual = nil
    }

    // MARK: - REST genérico

    /// GET com filtros estilo PostgREST (`coluna=eq.valor`).
    func selecionar<T: Decodable>(
        tabela: String,
        filtros: [String: String] = [:],
        ordem: String? = nil,
        limite: Int? = nil
    ) async throws -> [T] {
        var query: [String] = ["select=*"]
        for (chave, valor) in filtros {
            query.append("\(chave)=eq.\(valor)")
        }
        if let ordem { query.append("order=\(ordem)") }
        if let limite { query.append("limit=\(limite)") }
        let caminho = "/rest/v1/\(tabela)?" + query.joined(separator: "&")
        return try await requisicao(metodo: "GET", caminho: caminho, corpo: EmptyBody?.none, autenticado: true)
    }

    func inserir<TIn: Encodable, TOut: Decodable>(
        tabela: String,
        registro: TIn,
        retornar: Bool = true
    ) async throws -> TOut {
        let preferencia = retornar ? "return=representation" : "return=minimal"
        let respostaArray: [TOut] = try await requisicao(
            metodo: "POST",
            caminho: "/rest/v1/\(tabela)",
            corpo: registro,
            autenticado: true,
            cabecalhosExtras: ["Prefer": preferencia]
        )
        guard let primeiro = respostaArray.first else { throw SupabaseError.requisicaoInvalida }
        return primeiro
    }

    func atualizar<TIn: Encodable, TOut: Decodable>(
        tabela: String,
        registro: TIn,
        filtros: [String: String]
    ) async throws -> [TOut] {
        var query: [String] = []
        for (chave, valor) in filtros { query.append("\(chave)=eq.\(valor)") }
        let caminho = "/rest/v1/\(tabela)?" + query.joined(separator: "&")
        return try await requisicao(
            metodo: "PATCH",
            caminho: caminho,
            corpo: registro,
            autenticado: true,
            cabecalhosExtras: ["Prefer": "return=representation"]
        )
    }

    func remover(tabela: String, filtros: [String: String]) async throws {
        var query: [String] = []
        for (chave, valor) in filtros { query.append("\(chave)=eq.\(valor)") }
        let caminho = "/rest/v1/\(tabela)?" + query.joined(separator: "&")
        let _: EmptyResponse = try await requisicao(
            metodo: "DELETE",
            caminho: caminho,
            corpo: EmptyBody?.none,
            autenticado: true
        )
    }

    // MARK: - Internos

    private struct EmptyBody: Encodable {}
    private struct EmptyResponse: Decodable {}

    private func requisicao<TIn: Encodable, TOut: Decodable>(
        metodo: String,
        caminho: String,
        corpo: TIn?,
        autenticado: Bool,
        cabecalhosExtras: [String: String] = [:]
    ) async throws -> TOut {
        guard let url = URL(string: caminho, relativeTo: configuracao.url) else {
            throw SupabaseError.requisicaoInvalida
        }
        var requisicao = URLRequest(url: url)
        requisicao.httpMethod = metodo
        requisicao.setValue(configuracao.publishableKey, forHTTPHeaderField: "apikey")
        requisicao.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if autenticado {
            let token = sessaoAtual?.accessToken ?? configuracao.publishableKey
            requisicao.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        for (chave, valor) in cabecalhosExtras {
            requisicao.setValue(valor, forHTTPHeaderField: chave)
        }
        if let corpo {
            requisicao.httpBody = try encoder.encode(corpo)
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: requisicao)
        } catch {
            throw SupabaseError.rede(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.requisicaoInvalida
        }

        if http.statusCode == 401 || http.statusCode == 403 {
            throw SupabaseError.naoAutenticado
        }

        if !(200...299).contains(http.statusCode) {
            let mensagem = String(data: data, encoding: .utf8) ?? "(sem corpo)"
            throw SupabaseError.servidor(status: http.statusCode, mensagem: mensagem)
        }

        if TOut.self == EmptyResponse.self {
            return EmptyResponse() as! TOut
        }

        do {
            return try decoder.decode(TOut.self, from: data)
        } catch {
            throw SupabaseError.decodificacaoFalhou(error)
        }
    }
}
