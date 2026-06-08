import SwiftUI
import PhotosUI

/// Tela de Perfil — exibe avatar, dados pessoais, e dá entrada para
/// "Meus endereços". Botão de sair e excluir conta ficam em Settings.
struct PerfilView: View {
    @ObservedObject var perfilViewModel: PerfilViewModel
    @ObservedObject var enderecosViewModel: EnderecosViewModel
    @ObservedObject var authViewModel: AuthViewModel
    let dependencies: AppDependencies

    @State private var fotoSelecionada: PhotosPickerItem?
    @State private var editandoNome = false
    @State private var mostrandoExcluir = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DSSpacing.lg) {
                    cabecalhoAvatar
                    cardDados
                    cardEnderecos
                    cardPedidos
                    cardSessao
                }
                .padding(DSSpacing.lg)
            }
            .background(DSColor.groupedBackground)
            .navigationTitle("Meu perfil")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { enderecosViewModel.recarregar() }
            .onChange(of: fotoSelecionada) { _, novoItem in
                Task {
                    let data = try? await novoItem?.loadTransferable(type: Data.self)
                    perfilViewModel.aplicarImagemSelecionada(data)
                    perfilViewModel.salvar()
                }
            }
        }
    }

    // MARK: - Cabeçalho

    private var cabecalhoAvatar: some View {
        VStack(spacing: DSSpacing.md) {
            ZStack(alignment: .bottomTrailing) {
                avatarCircle
                PhotosPicker(selection: $fotoSelecionada, matching: .images) {
                    Image(systemName: "camera.fill")
                        .foregroundStyle(.white)
                        .padding(DSSpacing.xs)
                        .background(Circle().fill(DSColor.primary))
                        .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                }
                .accessibilityLabel("Alterar foto do perfil")
            }

            Text(perfilViewModel.nome)
                .font(DSFont.sectionTitle)
                .accessibilityAddTraits(.isHeader)

            Text(perfilViewModel.email)
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)

            Text(perfilViewModel.provedorBonito)
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(DSColor.primarySoft)
                .clipShape(Capsule())
        }
    }

    private var avatarCircle: some View {
        Group {
            if let data = perfilViewModel.avatarData, let imagem = UIImage(data: data) {
                Image(uiImage: imagem)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [DSColor.primarySoft, DSColor.primaryFaint],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text(perfilViewModel.usuario.iniciais)
                        .font(DSFont.screenTitle)
                        .foregroundStyle(DSColor.primary)
                }
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .accessibilityLabel("Foto do perfil de \(perfilViewModel.nome)")
    }

    // MARK: - Card dados

    private var cardDados: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            secao(titulo: "Dados pessoais")

            campoEditavel(
                rotulo: "Nome",
                valor: $perfilViewModel.nome,
                editando: $editandoNome
            )

            Divider()

            HStack {
                Text("E-mail").foregroundStyle(DSColor.textSecondary)
                Spacer()
                Text(perfilViewModel.email).fontWeight(.medium)
            }
            .accessibilityElement(children: .combine)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private func campoEditavel(rotulo: String, valor: Binding<String>, editando: Binding<Bool>) -> some View {
        HStack {
            Text(rotulo).foregroundStyle(DSColor.textSecondary)
            Spacer()
            if editando.wrappedValue {
                TextField(rotulo, text: valor)
                    .multilineTextAlignment(.trailing)
                    .submitLabel(.done)
                    .onSubmit {
                        perfilViewModel.salvar()
                        editando.wrappedValue = false
                    }
            } else {
                Text(valor.wrappedValue).fontWeight(.medium)
            }
            Button {
                if editando.wrappedValue { perfilViewModel.salvar() }
                editando.wrappedValue.toggle()
            } label: {
                Image(systemName: editando.wrappedValue ? "checkmark.circle.fill" : "pencil")
                    .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
            }
            .accessibilityLabel(editando.wrappedValue ? "Salvar \(rotulo)" : "Editar \(rotulo)")
        }
    }

    // MARK: - Card endereços

    private var cardEnderecos: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                secao(titulo: "Endereços de entrega")
                Spacer()
                Text("\(enderecosViewModel.total)")
                    .font(DSFont.metadata.weight(.semibold))
                    .foregroundStyle(DSColor.textSecondary)
            }

            if let padrao = enderecosViewModel.enderecos.first(where: { $0.ehPadrao }) {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    HStack {
                        Image(systemName: "star.fill").foregroundStyle(DSColor.primary)
                        Text(padrao.apelido).fontWeight(.semibold)
                    }
                    Text(padrao.linhaPrincipal).font(DSFont.body)
                    Text(padrao.linhaSecundaria).font(DSFont.metadata).foregroundStyle(DSColor.textSecondary)
                }
                .padding(DSSpacing.sm)
                .background(DSColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Endereço padrão: \(padrao.descricaoAcessivel)")
            } else if enderecosViewModel.estaVazio {
                Text("Nenhum endereço cadastrado.")
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
            }

            NavigationLink {
                EnderecosView(
                    viewModel: enderecosViewModel,
                    dependencies: dependencies,
                    usuarioId: perfilViewModel.usuario.id
                )
            } label: {
                Label("Gerenciar endereços", systemImage: "house.lodge.fill")
                    .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
            }
            .buttonStyle(.bordered)
            .tint(DSColor.primary)
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private func secao(titulo: String) -> some View {
        Text(titulo.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(DSColor.textSecondary)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Card de pedidos

    private var cardPedidos: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            secao(titulo: "Pedidos")
            NavigationLink {
                PedidosView(
                    viewModel: dependencies.makePedidosViewModel(usuarioId: perfilViewModel.usuario.id),
                    dependencies: dependencies
                )
            } label: {
                HStack {
                    Image(systemName: "bag.fill")
                        .foregroundStyle(DSColor.primary)
                        .frame(width: 24)
                        .accessibilityHidden(true)
                    Text("Meus pedidos").font(DSFont.body)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(DSColor.textSecondary)
                        .accessibilityHidden(true)
                }
                .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Abre a lista de pedidos com timeline de status.")
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    // MARK: - Card sessão (Sair + Excluir conta)

    private var cardSessao: some View {
        VStack(spacing: DSSpacing.sm) {
            NavigationLink {
                SobreView()
            } label: {
                Label("Sobre o app e termos", systemImage: "info.circle")
                    .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
            }
            .buttonStyle(.bordered)
            .tint(DSColor.primary)
            .accessibilityHint("Abre a tela com informacoes do app, equipe e politica de privacidade.")

            Button {
                authViewModel.sair()
            } label: {
                Label("Sair", systemImage: "rectangle.portrait.and.arrow.right")
                    .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
            }
            .buttonStyle(.bordered)
            .tint(DSColor.primary)
            .accessibilityHint("Encerra a sessao atual e volta para a tela de login.")

            Button(role: .destructive) {
                mostrandoExcluir = true
            } label: {
                Label("Excluir minha conta", systemImage: "trash")
                    .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Remove sua conta e todos os dados locais. Pede confirmacao.")
            .confirmationDialog(
                "Excluir minha conta?",
                isPresented: $mostrandoExcluir,
                titleVisibility: .visible
            ) {
                Button("Excluir conta", role: .destructive) {
                    authViewModel.excluirConta()
                }
                Button("Cancelar", role: .cancel) {}
            } message: {
                Text("Esta acao apaga seu usuario e dados locais. Em V1 com Supabase os dados sao removidos no servidor tambem (LGPD).")
            }
        }
    }
}
