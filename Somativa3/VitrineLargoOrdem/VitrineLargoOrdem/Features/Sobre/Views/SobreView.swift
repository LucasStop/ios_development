import SwiftUI

/// Tela "Sobre" — apresenta o projeto, integrantes, versão e links.
struct SobreView: View {

    private var versao: String {
        let bundle = Bundle.main
        let short = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = bundle.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Versão \(short) (build \(build))"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                hero

                secao(titulo: "Sobre o projeto") {
                    Text("A Vitrine da Feira do Largo da Ordem é o projeto somativo de SwiftUI da disciplina de Mobile Development iOS na PUCPR (2026). Apresenta produtos artesanais vendidos na tradicional feira de domingo no Largo da Ordem, em Curitiba.")
                    Text("Foi construído inteiramente em SwiftUI com SwiftData, MVVM, Repository Pattern, Acessibilidade rigorosa (VoiceOver, Dynamic Type) e Backend em Supabase com Row-Level Security.")
                }

                secao(titulo: "Equipe") {
                    pessoa(nome: "Lucas Stopinski da Silva", papel: "Desenvolvedor iOS")
                    Divider()
                    pessoa(nome: "Lucas Bruno e Silva", papel: "Desenvolvedor iOS")
                }

                secao(titulo: "Sobre o app") {
                    linha(rotulo: "Versão", valor: versao)
                    Divider()
                    linha(rotulo: "Disciplina", valor: "Mobile Development iOS")
                    Divider()
                    linha(rotulo: "Instituição", valor: "PUCPR")
                    Divider()
                    linha(rotulo: "Ano", valor: "2026")
                }

                secao(titulo: "Documentos") {
                    NavigationLink {
                        PoliticaPrivacidadeView()
                    } label: {
                        linkRow(simbolo: "lock.shield.fill", titulo: "Política de Privacidade")
                    }
                    Divider()
                    NavigationLink {
                        TermosUsoView()
                    } label: {
                        linkRow(simbolo: "doc.text.fill", titulo: "Termos de Uso")
                    }
                    Divider()
                    Link(destination: URL(string: "https://github.com/LucasStop/ios_development")!) {
                        linkRow(simbolo: "chevron.left.forwardslash.chevron.right", titulo: "Código-fonte no GitHub")
                    }
                    .accessibilityHint("Abre o repositorio em uma nova janela.")
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Sobre")
        .navigationBarTitleDisplayMode(.large)
    }

    private var hero: some View {
        VStack(spacing: DSSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DSColor.primarySoft, DSColor.primaryFaint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 110, height: 110)
                Image(systemName: "storefront.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(DSColor.primary)
                    .frame(width: 60, height: 60)
            }
            .accessibilityHidden(true)

            Text("Vitrine do Largo")
                .font(DSFont.screenTitle)
                .accessibilityAddTraits(.isHeader)

            Text("Feira do Largo da Ordem em Curitiba")
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func pessoa(nome: String, papel: String) -> some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundStyle(DSColor.primary)
                .frame(width: 24)
                .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(nome).font(DSFont.cardTitle)
                Text(papel)
                    .font(DSFont.metadata)
                    .foregroundStyle(DSColor.textSecondary)
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(nome), \(papel)")
    }

    private func linha(rotulo: String, valor: String) -> some View {
        HStack {
            Text(rotulo).foregroundStyle(DSColor.textSecondary)
            Spacer()
            Text(valor).fontWeight(.medium)
        }
        .accessibilityElement(children: .combine)
    }

    private func linkRow(simbolo: String, titulo: String) -> some View {
        HStack {
            Image(systemName: simbolo)
                .foregroundStyle(DSColor.primary)
                .frame(width: 24)
                .accessibilityHidden(true)
            Text(titulo).font(DSFont.body)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityHidden(true)
        }
        .frame(minHeight: DSSpacing.touchTargetMin)
        .contentShape(Rectangle())
    }

    private func secao<C: View>(titulo: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(titulo.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(DSColor.textSecondary)
                .accessibilityAddTraits(.isHeader)
            content()
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
