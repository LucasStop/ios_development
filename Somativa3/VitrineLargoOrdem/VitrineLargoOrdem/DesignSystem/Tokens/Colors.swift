import SwiftUI

/// Tokens de cor do Design System.
///
/// Todas as cores expostas no projeto devem vir daqui — referências diretas
/// a `.systemBlue`, `.gray` etc. em Views são proibidas a partir do MVP.
/// Permitem trocar paleta inteira em um único lugar e garantem coerência
/// entre Modo Claro e Modo Escuro via `UIColor`/`Color` dinâmicas do sistema.
enum DSColor {

    // MARK: - Marca

    /// Cor primária do app — usada em links, botões principais e destaques.
    static let primary = Color.accentColor

    /// Variante mais clara do primary — gradientes, fundos suaves.
    static let primarySoft = Color.accentColor.opacity(0.18)

    /// Variante muito clara do primary — backgrounds de cards e tags.
    static let primaryFaint = Color.accentColor.opacity(0.06)

    // MARK: - Superfícies

    /// Fundo principal de tela (claro/escuro automático).
    static let background = Color(.systemBackground)

    /// Fundo agrupado (cinza claro / preto suave).
    static let groupedBackground = Color(.systemGroupedBackground)

    /// Fundo de cards e elementos elevados.
    static let surface = Color(.secondarySystemBackground)

    /// Borda sutil (separadores, contornos de cards).
    static let border = Color(.separator).opacity(0.4)

    // MARK: - Texto

    /// Texto principal (preto/branco automático).
    static let textPrimary = Color.primary

    /// Texto secundário, legendas, metadados.
    static let textSecondary = Color.secondary

    /// Texto em fundo colorido (sempre branco).
    static let textOnAccent = Color.white

    // MARK: - Semântica

    /// Ações destrutivas, alertas, "tirar dos favoritos".
    static let danger = Color.red

    /// Sucessos, confirmações, status "entregue".
    static let success = Color.green

    /// Avisos, status "em produção".
    static let warning = Color.orange

    /// Estado "selecionado/favorito" — vermelho coração.
    static let favoriteActive = Color.red

    /// Estado "não favorito" — cinza neutro.
    static let favoriteInactive = Color.secondary
}
