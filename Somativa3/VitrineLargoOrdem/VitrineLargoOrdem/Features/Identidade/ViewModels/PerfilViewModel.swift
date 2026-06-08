import Foundation
import Combine
import UIKit

/// Estado do perfil do usuário atual — usado pela `PerfilView`.
@MainActor
final class PerfilViewModel: ObservableObject {

    @Published var nome: String
    @Published var avatarData: Data?

    private(set) var usuario: Usuario

    init(usuario: Usuario) {
        self.usuario = usuario
        self.nome = usuario.nome
        self.avatarData = usuario.avatarData
    }

    var email: String { usuario.email }
    var provedorBonito: String {
        switch usuario.provedor {
        case "apple": return "Conta Apple"
        case "email": return "E-mail e senha"
        case "convidado": return "Visitante"
        default: return usuario.provedor.capitalized
        }
    }

    func salvar() {
        let nomeLimpo = nome.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nomeLimpo.isEmpty else { return }
        usuario.nome = nomeLimpo
        usuario.avatarData = avatarData
    }

    /// Reduz a foto selecionada para no máximo 512x512 e JPEG 70% antes
    /// de persistir — mantém o banco enxuto para o protótipo MVP.
    func aplicarImagemSelecionada(_ data: Data?) {
        guard let data, let imagem = UIImage(data: data) else {
            avatarData = nil
            return
        }
        let tamanhoMax: CGFloat = 512
        let aspecto = imagem.size.width / imagem.size.height
        let tamanho: CGSize = imagem.size.width > imagem.size.height
            ? CGSize(width: tamanhoMax, height: tamanhoMax / aspecto)
            : CGSize(width: tamanhoMax * aspecto, height: tamanhoMax)

        let renderer = UIGraphicsImageRenderer(size: tamanho)
        let reduzida = renderer.image { _ in
            imagem.draw(in: CGRect(origin: .zero, size: tamanho))
        }
        avatarData = reduzida.jpegData(compressionQuality: 0.7)
    }
}
