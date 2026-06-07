import SwiftUI

/// Placeholder visual exibido enquanto produtos são carregados.
///
/// Usado em sequência (LazyVGrid com 6 cópias) para preencher a vitrine.
/// Animação shimmer suave evita "pop in" abrupto quando os dados chegam.
struct SkeletonCardView: View {

    @State private var brilhante = false

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            RoundedRectangle(cornerRadius: DSSpacing.cornerMd)
                .fill(skeletonGradient)
                .frame(height: 130)

            RoundedRectangle(cornerRadius: 4)
                .fill(skeletonGradient)
                .frame(height: 14)
                .frame(maxWidth: .infinity)

            RoundedRectangle(cornerRadius: 4)
                .fill(skeletonGradient)
                .frame(height: 10)
                .frame(maxWidth: .infinity * 0.6, alignment: .leading)

            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(skeletonGradient)
                    .frame(width: 70, height: 18)
                Spacer()
                Circle()
                    .fill(skeletonGradient)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(DSSpacing.sm)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous)
                .strokeBorder(DSColor.border, lineWidth: 1)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                brilhante.toggle()
            }
        }
        .accessibilityHidden(true)
    }

    private var skeletonGradient: LinearGradient {
        LinearGradient(
            colors: brilhante
                ? [DSColor.surface, DSColor.primaryFaint, DSColor.surface]
                : [DSColor.primaryFaint, DSColor.surface, DSColor.primaryFaint],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

/// Grid de N skeletons para preencher a tela enquanto carrega.
struct SkeletonGridView: View {
    let quantidade: Int

    private let colunas = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        LazyVGrid(columns: colunas, spacing: DSSpacing.md) {
            ForEach(0..<quantidade, id: \.self) { _ in
                SkeletonCardView()
            }
        }
        .padding(DSSpacing.md)
        .accessibilityHidden(true)
    }
}
