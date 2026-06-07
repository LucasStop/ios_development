import SwiftUI

/// 3 telas iniciais apresentando a proposta do app — exibidas apenas
/// na primeira execução. Após "Vamos começar" a flag em @AppStorage
/// impede que reapareçam.
struct OnboardingView: View {
    @Binding var jaViu: Bool

    @State private var paginaAtual: Int = 0

    private let paginas: [OnboardingPagina] = [
        OnboardingPagina(
            simbolo: "storefront.fill",
            titulo: "Bem-vindo à Feira",
            descricao: "Explore a tradicional Feira do Largo da Ordem direto do seu celular — artesanato, comidas e antiguidades curitibanas em um só lugar."
        ),
        OnboardingPagina(
            simbolo: "hand.tap.fill",
            titulo: "Descubra com calma",
            descricao: "Filtre por categoria, busque pelo que importa para você e salve seus favoritos para revisitar quando quiser."
        ),
        OnboardingPagina(
            simbolo: "heart.text.square.fill",
            titulo: "Conecte com artesãos",
            descricao: "Cada produto tem uma história — leia sobre quem o produziu e entre em contato direto com o artesão que assina a obra."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $paginaAtual) {
                ForEach(paginas.indices, id: \.self) { indice in
                    paginaView(paginas[indice])
                        .tag(indice)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            indicadores

            botoes
                .padding(.horizontal, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl)
        }
        .background(DSColor.groupedBackground.ignoresSafeArea())
    }

    private func paginaView(_ pagina: OnboardingPagina) -> some View {
        VStack(spacing: DSSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [DSColor.primarySoft, DSColor.primaryFaint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 220, height: 220)

                Image(systemName: pagina.simbolo)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(DSColor.primary)
                    .frame(width: 110, height: 110)
            }
            .accessibilityHidden(true)

            VStack(spacing: DSSpacing.md) {
                Text(pagina.titulo)
                    .font(DSFont.screenTitle)
                    .foregroundStyle(DSColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)

                Text(pagina.descricao)
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, DSSpacing.xl)

            Spacer()
        }
    }

    private var indicadores: some View {
        HStack(spacing: DSSpacing.xs) {
            ForEach(paginas.indices, id: \.self) { indice in
                Capsule()
                    .fill(indice == paginaAtual ? DSColor.primary : DSColor.border)
                    .frame(width: indice == paginaAtual ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: paginaAtual)
            }
        }
        .padding(.vertical, DSSpacing.md)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var botoes: some View {
        if paginaAtual == paginas.count - 1 {
            Button {
                jaViu = true
            } label: {
                Text("Vamos começar")
                    .font(DSFont.buttonLabel)
                    .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(DSColor.primary)
            .accessibilityHint("Conclui a apresentacao e abre a vitrine.")
        } else {
            HStack {
                Button("Pular") {
                    jaViu = true
                }
                .buttonStyle(.borderless)
                .foregroundStyle(DSColor.textSecondary)
                .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                .accessibilityHint("Pula a apresentacao e abre a vitrine.")

                Spacer()

                Button {
                    withAnimation { paginaAtual += 1 }
                } label: {
                    Text("Próximo")
                        .font(DSFont.buttonLabel)
                        .padding(.horizontal, DSSpacing.lg)
                        .frame(minHeight: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(DSColor.primary)
                .accessibilityHint("Avanca para a proxima tela da apresentacao.")
            }
        }
    }
}

private struct OnboardingPagina {
    let simbolo: String
    let titulo: String
    let descricao: String
}
