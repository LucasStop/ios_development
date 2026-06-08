import Foundation
import SwiftData

/// Contrato para autenticação.
///
/// V1 vai substituir `LocalAuthService` por um `SupabaseAuthService`
/// que troca tokens JWT com o backend — a UI não muda.
@MainActor
protocol AuthService: AnyObject {
    var usuarioAtual: Usuario? { get }

    /// Cadastra novo usuário com e-mail/senha. Lança `AuthError` em falha.
    func cadastrar(nome: String, email: String, senha: String) throws -> Usuario

    /// Faz login com e-mail/senha previamente cadastrados.
    func entrar(email: String, senha: String) throws -> Usuario

    /// Cria/autentica usuário via Sign in with Apple (mock).
    func entrarComApple(nome: String?, email: String?) throws -> Usuario

    /// Entra como convidado (sem persistência de identidade entre dispositivos).
    func entrarComoConvidado() throws -> Usuario

    /// Encerra a sessão atual.
    func sair()

    /// Apaga conta + dados associados (LGPD).
    func excluirConta() throws

    /// Apenas admins: altera o papel de um usuário existente.
    func alterarRole(emailAlvo: String, novaRole: RoleUsuario) throws
}

/// Implementação local com SwiftData. Usa UserDefaults para guardar
/// o ID da sessão atual e a tabela `CredencialUsuario` para o "banco
/// de senhas" (apenas hash SHA256 simples — não é segurança real,
/// é apenas demo acadêmica).
@MainActor
final class LocalAuthService: AuthService {

    private let context: ModelContext
    private let defaults: UserDefaults

    private let chaveSessao = "auth.sessaoUsuarioId"

    init(context: ModelContext, defaults: UserDefaults = .standard) {
        self.context = context
        self.defaults = defaults
    }

    var usuarioAtual: Usuario? {
        guard let idString = defaults.string(forKey: chaveSessao),
              let id = UUID(uuidString: idString)
        else { return nil }
        let descritor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.id == id })
        return try? context.fetch(descritor).first
    }

    // MARK: - Cadastro / Login

    func cadastrar(nome: String, email: String, senha: String) throws -> Usuario {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nomeLimpo.isEmpty else { throw AuthError.nomeObrigatorio }

        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        try validarEmail(emailLimpo)
        try validarSenha(senha)

        if usuarioComEmail(emailLimpo) != nil {
            throw AuthError.emailJaCadastrado
        }

        let usuario = Usuario(
            email: emailLimpo,
            nome: nomeLimpo,
            provedor: "email",
            role: roleInicial(emailLimpo)
        )
        let credencial = CredencialUsuario(email: emailLimpo, hashSenha: hash(senha))
        context.insert(usuario)
        context.insert(credencial)
        try? context.save()

        registrarSessao(usuario: usuario)
        return usuario
    }

    /// Regras para definir o papel inicial — paridade com o trigger Postgres.
    /// 1. Se nenhum usuário existir ainda → admin (bootstrap).
    /// 2. Se o e-mail começar com "admin@" → admin (atalho para demo).
    /// 3. Caso contrário → usuario.
    private func roleInicial(_ email: String) -> RoleUsuario {
        if email.hasPrefix("admin@") { return .admin }
        let descritor = FetchDescriptor<Usuario>()
        let totalExistente = (try? context.fetchCount(descritor)) ?? 0
        return totalExistente == 0 ? .admin : .usuario
    }

    /// Permite que um admin promova/rebaixe outro usuário pelo e-mail.
    /// Em produção isso seria delegado à function `promover_usuario` do
    /// Supabase (já criada no SQL 02-roles.sql).
    func alterarRole(emailAlvo: String, novaRole: RoleUsuario) throws {
        guard let atual = usuarioAtual, atual.ehAdmin else {
            throw AuthError.desconhecido("Apenas administradores podem alterar papéis.")
        }
        let emailLimpo = emailAlvo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let alvo = usuarioComEmail(emailLimpo) else {
            throw AuthError.desconhecido("Usuário com este e-mail não foi encontrado localmente.")
        }
        alvo.roleEnum = novaRole
        try? context.save()
    }

    func entrar(email: String, senha: String) throws -> Usuario {
        let emailLimpo = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let usuario = usuarioComEmail(emailLimpo),
              let credencial = credencialComEmail(emailLimpo),
              credencial.hashSenha == hash(senha) else {
            throw AuthError.credenciaisInvalidas
        }
        registrarSessao(usuario: usuario)
        return usuario
    }

    // MARK: - Apple / Convidado

    func entrarComApple(nome: String?, email: String?) throws -> Usuario {
        let emailFinal = (email ?? "usuario.apple@privado.local").lowercased()
        if let existente = usuarioComEmail(emailFinal) {
            registrarSessao(usuario: existente)
            return existente
        }
        let usuario = Usuario(
            email: emailFinal,
            nome: nome?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty ?? "Usuário Apple",
            provedor: "apple"
        )
        context.insert(usuario)
        try? context.save()
        registrarSessao(usuario: usuario)
        return usuario
    }

    func entrarComoConvidado() throws -> Usuario {
        let usuario = Usuario(
            email: "convidado@vitrine.local",
            nome: "Visitante",
            provedor: "convidado"
        )
        context.insert(usuario)
        try? context.save()
        registrarSessao(usuario: usuario)
        return usuario
    }

    // MARK: - Sair / Excluir

    func sair() {
        defaults.removeObject(forKey: chaveSessao)
    }

    func excluirConta() throws {
        guard let usuario = usuarioAtual else { return }
        // Apaga credencial e dados associados (LGPD - direito ao esquecimento).
        if let credencial = credencialComEmail(usuario.email) {
            context.delete(credencial)
        }
        // Carrinho e favoritos vinculados ao Usuario serão limpos quando
        // V1 introduzir userId nas tabelas. Por enquanto removemos o Usuario.
        context.delete(usuario)
        try? context.save()
        sair()
    }

    // MARK: - Helpers

    private func registrarSessao(usuario: Usuario) {
        defaults.set(usuario.id.uuidString, forKey: chaveSessao)
    }

    private func usuarioComEmail(_ email: String) -> Usuario? {
        let descritor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.email == email })
        return try? context.fetch(descritor).first
    }

    private func credencialComEmail(_ email: String) -> CredencialUsuario? {
        let descritor = FetchDescriptor<CredencialUsuario>(predicate: #Predicate { $0.email == email })
        return try? context.fetch(descritor).first
    }

    private func validarEmail(_ email: String) throws {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard email.range(of: regex, options: .regularExpression) != nil else {
            throw AuthError.emailInvalido
        }
    }

    private func validarSenha(_ senha: String) throws {
        guard senha.count >= 6 else { throw AuthError.senhaCurta }
    }

    /// Hash demo simples (XOR + base64). NÃO é seguro — apenas evita
    /// guardar senha em texto puro durante demos acadêmicas. V1 troca
    /// por Supabase Auth (bcrypt server-side).
    private func hash(_ senha: String) -> String {
        let bytes = senha.utf8.map { $0 ^ 0x5A }
        return Data(bytes).base64EncodedString()
    }
}

/// Armazena hash de senha localmente — apenas para o protótipo MVP.
@Model
final class CredencialUsuario {
    @Attribute(.unique) var email: String
    var hashSenha: String

    init(email: String, hashSenha: String) {
        self.email = email
        self.hashSenha = hashSenha
    }
}

private extension String {
    var nilIfEmpty: String? { isEmpty ? nil : self }
}
