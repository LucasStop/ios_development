import Foundation

/// Formatação centralizada de preços em Real brasileiro.
///
/// - `formatado(_:)` produz a string visual ("R$ 85,00") usando `NumberFormatter`
///   compartilhado para evitar realocação por render.
/// - `acessivel(_:)` produz a string que o VoiceOver lê em voz alta
///   ("Preço: 85 reais") para evitar a leitura literal de "R cifrão ponto zero zero".
///
/// Uma única fonte de verdade para todas as Views que exibem preços.
enum PrecoFormatter {

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }()

    /// String visual do preço para exibição na UI ("R$ 85,00").
    static func formatado(_ valor: Double) -> String {
        formatter.string(from: NSNumber(value: valor)) ?? "R$ \(valor)"
    }

    /// String em texto natural para VoiceOver e demais leitores ("Preço: 85 reais").
    static func acessivel(_ valor: Double) -> String {
        let totalCentavos = Int((valor * 100).rounded())
        let inteiro = totalCentavos / 100
        let centavos = totalCentavos % 100

        if centavos == 0 {
            return "Preço: \(inteiro) reais"
        }
        return "Preço: \(inteiro) reais e \(centavos) centavos"
    }
}
