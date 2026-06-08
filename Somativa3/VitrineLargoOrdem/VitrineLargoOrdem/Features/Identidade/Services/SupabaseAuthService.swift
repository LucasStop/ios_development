import Foundation
import SwiftData

/// Implementação de `AuthService` que delega autenticação para o
/// Supabase. Persiste localmente uma cópia do `Usuario` para
/// continuar funcionando offline e para repositórios SwiftData
/// terem a entidade a referenciar.
///
/// Em falhas de rede, faz fallback para a implementação local —
/// mantém a demo do MVP funcional mesmo sem internet.
@MainActor
final class SupabaseAuthService: AuthService {

    private let client: SupabaseClient
    private let context: ModelContext
    private let defaults: UserDefaults
    private let fallback: LocalAuthService

    private let chaveSessao = "auth.sessaoUsuarioId"

    init(client: SupabaseClient, context: ModelContext, defaults: UserDefaults = .standard) {
        self.client = client
        self.context = context
        self.defaults = defaults
        self.fallback = LocalAuthService(context: context, defaults: defaults)
    }

    var usuarioAtual: Usuario? {
        fallback.usuarioAtual
    }

    func cadastrar(nome: String, email: String, senha: String) throws -> Usuario {
        // Validações rápidas no local antes de chamar a rede.
        let local = try fallback.cadastrar(nome: nome, email: email, senha: senha)

        // Envia para Supabase em background. Se falhar (offline / e-mail
        // já cadastrado lá), mantemos o local — sincronização explícita
        // virá em outro PR.
        let emailLimpo = email.lowercased()
        Task { [client] in
            do {
                let resposta = try await client.cadastrar(email: emailLimpo, senha: senha, nome: nome)
                if resposta.sessao != nil {
                    print("[SupabaseAuth] ✅ cadastrar OK — sessão ativa, usuário: \(resposta.usuario.email ?? emailLimpo)")
                } else {
                    print("[SupabaseAuth] ⚠️ cadastrar OK — confirmação de e-mail pendente.")
                    print("[SupabaseAuth]    Desabilite 'Confirm email' em Authentication > Providers > Email.")
                }
            } catch {
                print("[SupabaseAuth] ❌ cadastrar falhou: \(error.localizedDescription)")
            }
        }
        return local
    }

    func entrar(email: String, senha: String) throws -> Usuario {
        // Tenta primeiro no local — cobre uso offline e sessões já existentes.
        if let usuarioLocal = try? fallback.entrar(email: email, senha: senha) {
            // Sincroniza token no background; ignorar erro.
            Task { [client] in _ = try? await client.entrar(email: email.lowercased(), senha: senha) }
            return usuarioLocal
        }

        // Usuário não encontrado localmente (ex.: reinstalou o app).
        // Para o MVP, orientamos o usuário a se cadastrar novamente —
        // sincronização cross-device seria feature de V2.
        throw AuthError.credenciaisInvalidas
    }

    func entrarComApple(nome: String?, email: String?) throws -> Usuario {
        try fallback.entrarComApple(nome: nome, email: email)
    }

    func entrarComoConvidado() throws -> Usuario {
        try fallback.entrarComoConvidado()
    }

    func sair() {
        fallback.sair()
        Task { await client.encerrarSessao() }
    }

    func excluirConta() throws {
        try fallback.excluirConta()
        // A exclusão remota é responsabilidade de uma Edge Function
        // chamada em background — fora do escopo do MVP.
    }

    func alterarRole(emailAlvo: String, novaRole: RoleUsuario) throws {
        // Aplica localmente para resposta imediata.
        try fallback.alterarRole(emailAlvo: emailAlvo, novaRole: novaRole)
        // Em paralelo dispara a RPC `promover_usuario` no Supabase.
        // Funções com SECURITY DEFINER já garantem a checagem de role
        // server-side; aqui apenas mandamos.
        Task { [client] in
            struct Payload: Encodable {
                let email_alvo: String
                let nova_role: String
            }
            do {
                let _: [RoleUsuarioRemoto] = try await client.inserir(
                    tabela: "rpc/promover_usuario",
                    registro: Payload(email_alvo: emailAlvo.lowercased(),
                                      nova_role: novaRole.rawValue)
                )
            } catch {
                print("[SupabaseAuth] alterarRole remote falhou: \(error.localizedDescription)")
            }
        }
    }

    private struct RoleUsuarioRemoto: Decodable {
        let id: String?
    }
}
