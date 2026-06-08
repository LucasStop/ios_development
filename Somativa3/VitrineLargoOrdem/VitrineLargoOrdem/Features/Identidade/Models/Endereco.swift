import Foundation
import SwiftData

/// Endereço de entrega vinculado ao usuário.
///
/// CEP é a chave de busca via ViaCEP (decisão 1 do plano);
/// usuário ainda pode editar os campos depois para corrigir bairro
/// ou número não preenchido pela API.
@Model
final class Endereco {
    @Attribute(.unique) var id: UUID
    var apelido: String          // "Casa", "Trabalho"
    var cep: String
    var logradouro: String
    var numero: String
    var complemento: String
    var bairro: String
    var cidade: String
    var uf: String
    var ehPadrao: Bool
    var criadoEm: Date
    var usuarioId: UUID

    init(
        id: UUID = UUID(),
        apelido: String,
        cep: String,
        logradouro: String,
        numero: String,
        complemento: String = "",
        bairro: String,
        cidade: String,
        uf: String,
        ehPadrao: Bool = false,
        criadoEm: Date = .now,
        usuarioId: UUID
    ) {
        self.id = id
        self.apelido = apelido
        self.cep = cep
        self.logradouro = logradouro
        self.numero = numero
        self.complemento = complemento
        self.bairro = bairro
        self.cidade = cidade
        self.uf = uf
        self.ehPadrao = ehPadrao
        self.criadoEm = criadoEm
        self.usuarioId = usuarioId
    }

    /// Linha 1 do endereço para exibição: "Rua X, 123 — Apto 45".
    var linhaPrincipal: String {
        var partes = ["\(logradouro), \(numero)"]
        if !complemento.isEmpty { partes.append(complemento) }
        return partes.joined(separator: " — ")
    }

    /// Linha 2 do endereço: "Bairro · Cidade/UF · CEP 80020-000".
    var linhaSecundaria: String {
        let cepFormatado = Self.formatarCEP(cep)
        return "\(bairro) · \(cidade)/\(uf) · CEP \(cepFormatado)"
    }

    /// Versão acessível para VoiceOver (sem siglas, com pausa natural).
    var descricaoAcessivel: String {
        let cepFormatado = Self.formatarCEP(cep)
        var texto = "\(apelido). \(logradouro), número \(numero)"
        if !complemento.isEmpty { texto += ", \(complemento)" }
        texto += ". Bairro \(bairro). \(cidade), \(uf). CEP \(cepFormatado)."
        if ehPadrao { texto += " Endereço padrão." }
        return texto
    }

    static func formatarCEP(_ cep: String) -> String {
        let apenasDigitos = cep.filter { $0.isNumber }
        guard apenasDigitos.count == 8 else { return cep }
        let inicio = apenasDigitos.prefix(5)
        let fim = apenasDigitos.suffix(3)
        return "\(inicio)-\(fim)"
    }
}
