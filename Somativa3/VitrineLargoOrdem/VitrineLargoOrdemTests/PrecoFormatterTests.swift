import Testing
@testable import VitrineLargoOrdem

/// Garante que o `PrecoFormatter` produz strings corretas tanto para
/// exibição quanto para VoiceOver — especialmente o fix do bug de
/// centavos com arredondamento de Double (review adversarial anterior).
struct PrecoFormatterTests {

    @Test func formatadoUsaPadraoBrasileiro() {
        let resultado = PrecoFormatter.formatado(85.00)
        #expect(resultado.contains("R$"))
        #expect(resultado.contains("85"))
    }

    @Test func acessivelLeApenasReaisQuandoNaoHaCentavos() {
        #expect(PrecoFormatter.acessivel(85.00) == "Preço: 85 reais")
        #expect(PrecoFormatter.acessivel(0.00) == "Preço: 0 reais")
        #expect(PrecoFormatter.acessivel(1000.00) == "Preço: 1000 reais")
    }

    @Test func acessivelInclueCentavosQuandoHaFracao() {
        #expect(PrecoFormatter.acessivel(12.50) == "Preço: 12 reais e 50 centavos")
        #expect(PrecoFormatter.acessivel(99.99) == "Preço: 99 reais e 99 centavos")
    }

    /// Cobre o bug de Double identificado no review — 12.10 não pode virar
    /// "12 reais e 9 centavos" por causa de 0.099999... no ponto flutuante.
    @Test func acessivelArredondaCentavosCorretamente() {
        #expect(PrecoFormatter.acessivel(12.10) == "Preço: 12 reais e 10 centavos")
        #expect(PrecoFormatter.acessivel(45.20) == "Preço: 45 reais e 20 centavos")
        #expect(PrecoFormatter.acessivel(7.30) == "Preço: 7 reais e 30 centavos")
    }
}
