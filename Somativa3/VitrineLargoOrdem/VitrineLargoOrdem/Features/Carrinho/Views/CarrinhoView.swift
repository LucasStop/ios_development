import SwiftUI

struct CarrinhoView: View {
    @ObservedObject var viewModel: CarrinhoViewModel
    let dependencies: AppDependencies?
    let usuarioId: UUID?

    @State private var mostrandoConfirmacaoLimpar = false
    @State private var mostrandoConfirmacaoCompra = false
    @State private var checkoutAberto = false

    init(viewModel: CarrinhoViewModel, dependencies: AppDependencies? = nil, usuarioId: UUID? = nil) {
        self.viewModel = viewModel
        self.dependencies = dependencies
        self.usuarioId = usuarioId
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.estaVazio {
                    estadoVazio
                } else {
                    lista
                }
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Carrinho")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !viewModel.estaVazio {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Limpar", role: .destructive) {
                            mostrandoConfirmacaoLimpar = true
                        }
                        .accessibilityHint("Remove todos os itens do carrinho.")
                    }
                }
            }
            .alert("Limpar carrinho?", isPresented: $mostrandoConfirmacaoLimpar) {
                Button("Cancelar", role: .cancel) {}
                Button("Limpar tudo", role: .destructive) {
                    viewModel.limpar()
                }
            } message: {
                Text("Esta ação remove todos os \(viewModel.totalDeItens) itens do carrinho. Não pode ser desfeita.")
            }
            .alert("Pedido confirmado!", isPresented: $mostrandoConfirmacaoCompra) {
                Button("OK", role: .cancel) {
                    viewModel.limpar()
                }
            } message: {
                Text("Seu pedido de \(viewModel.totalFormatado) foi recebido. Esta é uma confirmação fictícia do MVP.")
            }
            .fullScreenCover(isPresented: $checkoutAberto, onDismiss: { viewModel.recarregar() }) {
                if let deps = dependencies, let userId = usuarioId {
                    CheckoutView(
                        viewModel: deps.makeCheckoutViewModel(
                            carrinhoViewModel: viewModel,
                            usuarioId: userId
                        ),
                        dependencies: deps
                    )
                }
            }
        }
    }

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Carrinho vazio", systemImage: "cart")
        } description: {
            Text("Toque em um produto da vitrine e adicione ao carrinho para começar.")
        }
        .accessibilityElement(children: .combine)
    }

    private var lista: some View {
        ScrollView {
            VStack(spacing: DSSpacing.md) {
                ForEach(viewModel.itens) { item in
                    CartItemRowView(
                        item: item,
                        onIncrement: { viewModel.incrementar(item: item) },
                        onDecrement: { viewModel.decrementar(item: item) },
                        onRemove: { viewModel.remover(item: item) }
                    )
                }

                resumoFinanceiro
                botaoFinalizar
            }
            .padding(DSSpacing.md)
        }
    }

    private var resumoFinanceiro: some View {
        VStack(spacing: DSSpacing.sm) {
            linhaResumo(rotulo: "Subtotal",
                        valor: viewModel.subtotalFormatado,
                        valorAcessivel: viewModel.subtotalAcessivel,
                        destacado: false)
            Divider()
            linhaResumo(rotulo: "Frete",
                        valor: viewModel.freteFormatado,
                        valorAcessivel: viewModel.freteAcessivel,
                        destacado: false)
            Divider()
            linhaResumo(rotulo: "Total",
                        valor: viewModel.totalFormatado,
                        valorAcessivel: viewModel.totalAcessivel,
                        destacado: true)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private func linhaResumo(rotulo: String, valor: String, valorAcessivel: String, destacado: Bool) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(rotulo)
                .font(destacado ? DSFont.cardTitle : DSFont.body)
                .foregroundStyle(destacado ? DSColor.textPrimary : DSColor.textSecondary)
            Spacer(minLength: DSSpacing.sm)
            Text(valor)
                .font(destacado ? DSFont.precoDestaque : DSFont.body)
                .fontWeight(destacado ? .bold : .medium)
                .foregroundStyle(destacado ? DSColor.primary : DSColor.textPrimary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rotulo): \(valorAcessivel)")
    }

    private var botaoFinalizar: some View {
        Button {
            if dependencies != nil && usuarioId != nil {
                checkoutAberto = true
            } else {
                mostrandoConfirmacaoCompra = true
            }
        } label: {
            Label("Ir para o checkout", systemImage: "creditcard.fill")
                .font(DSFont.buttonLabel)
                .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .tint(DSColor.primary)
        .accessibilityHint("Abre o checkout em 4 etapas para finalizar o pedido.")
    }
}
