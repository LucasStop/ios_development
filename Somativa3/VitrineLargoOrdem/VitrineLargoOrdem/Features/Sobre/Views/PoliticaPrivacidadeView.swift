import SwiftUI

/// Política de Privacidade exibida dentro do app — texto resumido,
/// adequado a contexto acadêmico/demonstrativo. Em produção o texto
/// formal vem do jurídico.
struct PoliticaPrivacidadeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                cabecalho

                secao(titulo: "1. Quem somos") {
                    Text("A Vitrine da Feira do Largo da Ordem é um projeto acadêmico da PUCPR (2026), desenvolvido como avaliação Somativa SwiftUI. O app conecta visitantes a artesãos da feira de domingo no Largo da Ordem, em Curitiba.")
                }

                secao(titulo: "2. Dados que coletamos") {
                    Text("Coletamos somente o necessário para operar o app:")
                    Bullet("E-mail e nome no cadastro (e foto, opcional, escolhida na sua galeria)")
                    Bullet("Endereços que você cadastra para entrega")
                    Bullet("Pedidos realizados e seus itens")
                    Bullet("Favoritos e itens no carrinho — para você não perder o progresso")
                    Text("Não coletamos localização, contatos, agenda, microfone ou câmera além da foto explicitamente selecionada por você.")
                }

                secao(titulo: "3. Como armazenamos") {
                    Text("Tudo é guardado em duas camadas:")
                    Bullet("Localmente no seu iPhone via SwiftData (banco encriptado pelo iOS)")
                    Bullet("No Supabase — banco Postgres hospedado em São Paulo, com Row-Level Security garantindo que cada usuário enxergue apenas os próprios dados")
                    Text("Senhas nunca trafegam ou ficam armazenadas em texto puro.")
                }

                secao(titulo: "4. Com quem compartilhamos") {
                    Text("Nenhum dado é vendido nem cedido para terceiros. Os únicos serviços externos usados são:")
                    Bullet("Supabase — backend de autenticação e banco de dados")
                    Bullet("ViaCEP — apenas o CEP é enviado, retorna logradouro, bairro, cidade e UF")
                }

                secao(titulo: "5. Seus direitos (LGPD)") {
                    Text("Conforme a Lei Geral de Proteção de Dados (Lei 13.709/2018) você pode:")
                    Bullet("Acessar seus dados — toda informação está visível na aba Perfil")
                    Bullet("Corrigir nome, foto e endereços a qualquer momento")
                    Bullet("Excluir sua conta — usa o botão Excluir minha conta na aba Perfil. A ação apaga tudo localmente e dispara remoção remota também.")
                    Bullet("Solicitar portabilidade — entre em contato pelo e-mail abaixo")
                }

                secao(titulo: "6. Cookies e rastreio") {
                    Text("O app NÃO usa cookies, NÃO faz tracking publicitário e NÃO compartilha dados com redes sociais. Como ainda não temos analytics em produção, também não exibimos o prompt App Tracking Transparency — quando integrarmos TelemetryDeck (privacy-first), nenhum identificador pessoal será enviado.")
                }

                secao(titulo: "7. Crianças") {
                    Text("Este app é direcionado a maiores de 18 anos por envolver compra de produtos. Não coletamos intencionalmente dados de menores; se identificarmos cadastro de criança, a conta é excluída.")
                }

                secao(titulo: "8. Mudanças nesta política") {
                    Text("Versões futuras desta política aparecerão aqui com a data de atualização. O cabeçalho indica a versão vigente.")
                }

                secao(titulo: "9. Contato") {
                    Text("Dúvidas ou solicitações?")
                    Bullet("E-mail: lucas.stopinski@pucpr.edu.br")
                    Bullet("Repositório: github.com/LucasStop/ios_development")
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Política de Privacidade")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var cabecalho: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Política de Privacidade")
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
