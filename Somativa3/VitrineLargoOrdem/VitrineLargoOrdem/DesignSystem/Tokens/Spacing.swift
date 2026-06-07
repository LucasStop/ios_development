import Foundation
import SwiftUI

/// Tokens de espaçamento do Design System.
///
/// Escala 4-8 pontos para alinhamento consistente em todo o app.
/// Toda margem, padding e gap deve vir daqui — números mágicos
/// (`16`, `24`, `32`) em Views são proibidos a partir do MVP.
enum DSSpacing {

    // MARK: - Escala base

    /// 4pt — separação mínima entre elementos correlatos.
    static let xxs: CGFloat = 4

    /// 8pt — separação dentro de um componente (ex: ícone + texto).
    static let xs: CGFloat = 8

    /// 12pt — gap padrão entre elementos próximos em um card.
    static let sm: CGFloat = 12

    /// 16pt — padding padrão de cards e seções.
    static let md: CGFloat = 16

    /// 20pt — espaçamento entre blocos de informação na tela de detalhes.
    static let lg: CGFloat = 20

    /// 24pt — separação entre seções de uma tela.
    static let xl: CGFloat = 24

    /// 32pt — margens generosas e respiração no topo/base.
    static let xxl: CGFloat = 32

    // MARK: - Raios de canto

    /// Raio de canto pequeno (chips, badges).
    static let cornerSm: CGFloat = 8

    /// Raio de canto médio (cards e botões).
    static let cornerMd: CGFloat = 12

    /// Raio de canto grande (cards principais).
    static let cornerLg: CGFloat = 16

    /// Raio de canto extra grande (imagens grandes da tela de detalhes).
    static let cornerXl: CGFloat = 20

    // MARK: - Acessibilidade

    /// Touch target mínimo (Apple HIG: 44pt).
    /// Usar como `.frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)`.
    static let touchTargetMin: CGFloat = 44
}
