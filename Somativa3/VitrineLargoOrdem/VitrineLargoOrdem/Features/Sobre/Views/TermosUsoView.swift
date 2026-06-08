import SwiftUI

/// Termos de Uso resumidos do app — formato semelhante à Política
/// de Privacidade para consistência visual.
struct TermosUsoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                cabecalho

                secao(titulo: "1. Aceite") {
                    Text("Ao criar uma conta ou continuar como visitante você concorda com estes termos. Se discordar de qualquer ponto, encerre o uso do app.")
                }

                secao(titulo: "2. Objetivo do app") {
                    Text("A Vitrine da Feira do Largo da Ordem é uma plataforma de demonstração acadêmica que apresenta produtos artesanais curitibanos. As compras finalizadas atualmente são mock para fins de avaliação — não há cobrança real nem envio físico.")
                }

                secao(titulo: "3. Conta de usuário") {
                    Text("Você é responsável pelo sigilo de sua senha. Use uma senha forte com pelo menos 6 caracteres. Caso suspeite de acesso indevido, troque imediatamente ou exclua a conta.")
                }

                secao(titulo: "4. Conduta") {
                    Text("Não é permitido:")
                    Bullet("Cadastrar dados falsos ou ofensivos")
                    Bullet("Tentar acessar dados de outros usuários")
                    Bullet("Burlar limitações técnicas do app (jailbreak, engenharia reversa para fins maliciosos)")
                }

                secao(titulo: "5. Propriedade intelectual") {
                    Text("Imagens de produtos, descrições e o código-fonte são parte do trabalho acadêmico de Lucas Stopinski e Lucas Bruno (PUCPR). Reprodução comercial requer autorização explícita.")
                }

                secao(titulo: "6. Disponibilidade") {
                    Text("Como projeto acadêmico, não garantimos disponibilidade contínua. O app funciona offline-first, mas funções dependentes do Supabase podem ficar indisponíveis sem aviso.")
                }

                secao(titulo: "7. Limitação de responsabilidade") {
                    Text("O app é fornecido \"como está\". Não nos responsabilizamos por perdas decorrentes de uso indevido, falhas de rede ou de hardware do dispositivo.")
                }

                secao(titulo: "8. Modificações") {
                    Text("Estes termos podem ser revistos a qualquer momento. A versão vigente aparece sempre neste local com a data correspondente.")
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Termos de Uso")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var cabecalho: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Termos de Uso")
                .font(DSFont.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Text("Versão 1.0 · Vigente a partir de junho/2026")
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
        }
    }

    private func secao<C: View>(titulo: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(titulo)
                .font(DSFont.sectionTitle)
                .accessibilityAddTraits(.isHeader)
            content()
                .font(DSFont.body)
                .foregroundStyle(DSColor.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private struct Bullet: View {
        let texto: String
        init(_ texto: String) { self.texto = texto }
        var body: some View {
            HStack(alignment: .top, spacing: DSSpacing.xs) {
                Text("•").bold()
                Text(texto)
            }
        }
    }
}
