import SwiftUI

struct EnderecosView: View {
    @ObservedObject var viewModel: EnderecosViewModel
    let dependencies: AppDependencies
    let usuarioId: UUID

    @State private var formAberto: Bool = false
    @State private var enderecoEditando: Endereco?

    var body: some View {
        Group {
            if viewModel.estaVazio {
                estadoVazio
            } else {
                lista
            }
        }
        .background(DSColor.groupedBackground)
        .navigationTitle("Meus endereços")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    enderecoEditando = nil
                    formAberto = true
                } label: {
                    Label("Novo endereço", systemImage: "plus")
                }
                .accessibilityHint("Abre o formulário para cadastrar um novo endereço.")
            }
        }
        .sheet(isPresented: $formAberto, onDismiss: { viewModel.recarregar() }) {
            EnderecoFormView(
                viewModel: dependencies.makeEnderecoFormViewModel(
                    usuarioId: usuarioId,
                    editando: enderecoEditando
                )
            )
        }
        .onAppear { viewModel.recarregar() }
    }

    private var estadoVazio: some View {
        ContentUnavailableView {
            Label("Sem endereços cadastrados", systemImage: "house")
        } description: {
            Text("Cadastre seu primeiro endereço para agilizar o checkout.")
        } actions: {
            Button {
                enderecoEditando = nil
                formAberto = true
            } label: {
                Label("Adicionar endereço", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(DSColor.primary)
        }
    }

    private var lista: some View {
        List {
            ForEach(viewModel.enderecos) { endereco in
                EnderecoRowView(
                    endereco: endereco,
                    onEditar: {
                        enderecoEditando = endereco
                        formAberto = true
                    },
                    onTornarPadrao: { viewModel.definirComoPadrao(endereco) },
                    onRemover: { viewModel.remover(endereco) }
                )
                .listRowBackground(DSColor.background)
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}

private struct EnderecoRowView: View {
    let endereco: Endereco
    let onEditar: () -> Void
    let onTornarPadrao: () -> Void
    let onRemover: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            HStack {
                Text(endereco.apelido)
                    .font(DSFont.cardTitle)
                if endereco.ehPadrao {
                    Text("Padrão")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, DSSpacing.xs)
                        .padding(.vertical, 2)
                        .background(DSColor.primarySoft)
                        .foregroundStyle(DSColor.primary)
                        .clipShape(Capsule())
                }
            }
            Text(endereco.linhaPrincipal)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textPrimary)
            Text(endereco.linhaSecundaria)
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
        }
        .padding(.vertical, DSSpacing.xxs)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(endereco.descricaoAcessivel)
        .accessibilityHint("Deslize para remover, editar ou definir como padrão.")
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onRemover) {
                Label("Remover", systemImage: "trash")
            }
            Button(action: onEditar) {
                Label("Editar", systemImage: "pencil")
            }
            .tint(.blue)
            if !endereco.ehPadrao {
                Button(action: onTornarPadrao) {
                    Label("Padrão", systemImage: "star")
                }
                .tint(.orange)
            }
        }
    }
}
