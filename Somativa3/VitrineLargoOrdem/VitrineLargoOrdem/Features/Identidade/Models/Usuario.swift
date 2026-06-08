import Foundation
import SwiftData

/// Usuário autenticado no app — perfil local até V1 trazer backend real.
///
/// Apenas uma entidade `Usuario` existe por vez (a sessão atual).
/// Quando V1 trouxer Supabase Auth, este modelo passa a ser DTO
/// mapeado do JWT + tabela `users` no Postgres.
@Model
final class Usuario {
    @Attribute(.unique) var id: UUID
    var email: String
    var nome: String
    var provedor: String // "apple", "email", "convidado"
    var role: String     // "usuario" | "admin"
    var criadoEm: Date
    var avatarData: Data?

    init(
        id: UUID = UUID(),
        email: String,
        nome: String,
        provedor: String,
        role: RoleUsuario = .usuario,
        criadoEm: Date = .now,
        avatarData: Data? = nil
    ) {
        self.id = id
        self.email = email
        self.nome = nome
        self.provedor = provedor
        self.role = role.rawValue
        self.criadoEm = criadoEm
        self.avatarData = avatarData
    }

    /// Iniciais para fallback quando não há avatar (usado em UI).
    var iniciais: String {
        let partes = nome.split(separator: " ")
        let primeira = partes.first?.prefix(1) ?? ""
        let ultima = partes.count > 1 ? (partes.last?.prefix(1) ?? "") : ""
        return String(primeira + ultima).uppercased()
    }

    var roleEnum: RoleUsuario {
        get { RoleUsuario(rawValue: role) ?? .usuario }
        set { role = newValue.rawValue }
    }

    var ehAdmin: Bool { roleEnum == .admin }
}

/// Papéis de autorização. Por padrão todo usuário é `usuario` —
/// `admin` precisa ser concedido por outro admin ou (em demos) é
/// atribuído ao primeiro cadastrado.
enum RoleUsuario: String, CaseIterable, Identifiable, Codable {
    case usuario
    case admin

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .usuario: return "Usuário"
        case .admin: return "Administrador"
        }
    }

    var simbolo: String {
        switch self {
        case .usuario: return "person.fill"
        case .admin: return "person.badge.shield.checkmark.fill"
        }
    }
}

/// Erros de autenticação reportados ao usuário.
enum AuthError: LocalizedError, Equatable {
    case credenciaisInvalidas
    case emailJaCadastrado
    case senhaCurta
    case emailInvalido
    case nomeObrigatorio
    case desconhecido(String)

    var errorDescription: String? {
        switch self {
        case .credenciaisInvalidas: return "E-mail ou senha incorretos."
        case .emailJaCadastrado: return "Este e-mail já está cadastrado."
        case .senhaCurta: return "A senha precisa de pelo menos 6 caracteres."
        case .emailInvalido: return "Informe um e-mail válido."
        case .nomeObrigatorio: return "Informe seu nome."
        case .desconhecido(let descricao): return descricao
        }
    }
}
