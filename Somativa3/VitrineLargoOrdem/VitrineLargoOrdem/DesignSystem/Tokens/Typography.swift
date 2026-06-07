import SwiftUI

/// Tokens de tipografia do Design System.
///
/// Sempre usar `Font` semânticas (`.headline`, `.body`...) e nunca `.system(size:)`
/// fixo para preservar Dynamic Type. Os tokens aqui apenas dão nome semântico
/// para os estilos mais usados no app (ex: `DSFont.preco`), evitando duplicar
/// configuração de fontWeight.
enum DSFont {

    // MARK: - Títulos

    /// Título grande de tela (NavigationStack large title).
    static let screenTitle = Font.largeTitle.weight(.bold)

    /// Título de seção dentro de uma tela.
    static let sectionTitle = Font.title2.weight(.semibold)

    /// Título de card / item de lista.
    static let cardTitle = Font.headline

    // MARK: - Conteúdo

    /// Texto longo (descrições, parágrafos).
    static let body = Font.body

    /// Texto secundário / metadados (categoria, ano, autor).
    static let metadata = Font.caption

    /// Texto pequeno auxiliar (helper texts, hints).
    static let small = Font.footnote

    // MARK: - Componentes

    /// Preço em destaque (card e tela de detalhes).
    static let preco = Font.headline

    /// Preço em destaque maior (resumo de pedido, total).
    static let precoDestaque = Font.title3.weight(.bold)

    /// Texto de botão primário.
    static let buttonLabel = Font.headline
}
