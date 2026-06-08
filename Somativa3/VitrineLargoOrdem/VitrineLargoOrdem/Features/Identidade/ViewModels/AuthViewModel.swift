import Foundation
import Combine

/// Estado global de autenticação. Fica como `@StateObject` no App
/// para coordenar o AuthGate entre Login e Conteúdo principal.
@MainActor
final class AuthViewModel: ObservableObject {

    enum Modo: String {
        case login
        case cadastro
    }

    @Published var modo: Modo = .login

    // Formulário
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var senha: String = ""

    @Published private(set) var usuarioAtual: Usuario?
    @Published private(set) var carregando: Bool = false
    @Published var erro: AuthError?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        self.usuarioAtual = authService.usuarioAtual
    }

    var estaAutenticado: Bool { usuarioAtual != nil }

    var formularioValido: Bool {
        switch modo {
        case .login:
            return !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && senha.count >= 6
        case .cadastro:
            return !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && senha.count >= 6
        }
    }

    func alternarModo() {
        modo = (modo == .login) ? .cadastro : .login
        erro = nil
    }

    func submeter() {
        erro = nil
        carregando = true
        defer { carregando = false }

        do {
            switch modo {
            case .login:
                let usuario = try authService.entrar(email: email, senha: senha)
                aoEntrar(usuario)
            case .cadastro:
                let usuario = try authService.cadastrar(nome: nome, email: email, senha: senha)
                aoEntrar(usuario)
            }
        } catch let authError as AuthError {
            erro = authError
        } catch {
            erro = .desconhecido(error.localizedDescription)
        }
    }

    func entrarComoConvidado() {
        erro = nil
        do {
            let usuario = try authService.entrarComoConvidado()
            aoEntrar(usuario)
        } catch let authError as AuthError {
            erro = authError
        } catch {
            erro = .desconhecido(error.localizedDescription)
        }
    }

    func sair() {
        authService.sair()
        usuarioAtual = nil
        nome = ""
        email = ""
        senha = ""
    }

    func excluirConta() {
        do {
            try authService.excluirConta()
            usuarioAtual = nil
            nome = ""
            email = ""
            senha = ""
        } catch {
            erro = .desconhecido(error.localizedDescription)
        }
    }

    private func aoEntrar(_ usuario: Usuario) {
        usuarioAtual = usuario
        nome = ""
        senha = ""
    }
}
