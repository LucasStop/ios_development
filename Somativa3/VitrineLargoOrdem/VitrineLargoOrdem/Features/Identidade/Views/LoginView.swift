import SwiftUI

/// Tela de autenticação inicial. Permite cadastro/login com e-mail
/// (via Supabase Auth quando integrado, hoje via LocalAuthService)
/// e modo convidado para demonstração.
struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: DSSpacing.xl) {
                cabecalho
                    .padding(.top, DSSpacing.xxl)

                formulario
                divisor
                ajudaConvidado
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColor.groupedBackground.ignoresSafeArea())
        .alert("Não foi possível continuar",
               isPresented: Binding(get: { viewModel.erro != nil }, set: { _ in viewModel.erro = nil })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.erro?.errorDescription ?? "")
        }
    }

    private var cabecalho: some View {
        VStack(spacing: DSSpacing.md) {
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
                    .frame(width: 56, height: 56)
            }
            .accessibilityHidden(true)

            Text(viewModel.modo == .login ? "Bem-vindo de volta" : "Crie sua conta")
                .font(DSFont.screenTitle)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.modo == .login
                 ? "Entre para acompanhar pedidos, favoritos e endereços."
                 : "Em segundos você está pronto para explorar a feira.")
                .font(DSFont.body)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private var formulario: some View {
        VStack(spacing: DSSpacing.md) {
            if viewModel.modo == .cadastro {
                campoTexto(titulo: "Nome", texto: $viewModel.nome,
                           sistema: "person.fill", textContentType: .name)
            }
            campoTexto(titulo: "E-mail", texto: $viewModel.email,
                       sistema: "envelope.fill",
                       keyboard: .emailAddress,
                       textContentType: .emailAddress)
            campoSenha(titulo: "Senha", texto: $viewModel.senha)

            Button {
                viewModel.submeter()
            } label: {
                Group {
                    if viewModel.carregando {
                        ProgressView()
                    } else {
                        Text(viewModel.modo == .login ? "Entrar" : "Criar conta")
                            .font(DSFont.buttonLabel)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(DSColor.primary)
            .disabled(!viewModel.formularioValido || viewModel.carregando)
            .accessibilityHint(viewModel.modo == .login
                               ? "Faz login com e-mail e senha."
                               : "Cadastra um novo usuario com e-mail e senha.")

            Button {
                viewModel.alternarModo()
            } label: {
                Text(viewModel.modo == .login
                     ? "Não tem conta? Crie uma agora"
                     : "Já tem conta? Entrar")
                    .font(DSFont.body)
            }
            .frame(minHeight: DSSpacing.touchTargetMin)
            .accessibilityHint("Alterna entre os modos de cadastro e login.")
        }
        .padding(DSSpacing.md)
        .background(DSColor.background)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerLg, style: .continuous))
    }

    private var divisor: some View {
        HStack {
            Rectangle().fill(DSColor.border).frame(height: 1)
            Text("ou")
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
                .padding(.horizontal, DSSpacing.sm)
            Rectangle().fill(DSColor.border).frame(height: 1)
        }
    }

    private var ajudaConvidado: some View {
        VStack(spacing: DSSpacing.xs) {
            Button("Continuar como convidado") {
                viewModel.entrarComoConvidado()
            }
            .buttonStyle(.borderless)
            .foregroundStyle(DSColor.textSecondary)
            .frame(minHeight: DSSpacing.touchTargetMin)
            .accessibilityHint("Acessa o app sem cadastro. Seu progresso fica apenas neste aparelho.")

            Text("Visitantes não recebem confirmação de pedido por e-mail.")
                .font(DSFont.metadata)
                .foregroundStyle(DSColor.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private func campoTexto(
        titulo: String,
        texto: Binding<String>,
        sistema: String,
        keyboard: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: sistema)
                .foregroundStyle(DSColor.textSecondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            TextField(titulo, text: texto)
                .textContentType(textContentType)
                .keyboardType(keyboard)
                .autocapitalization(keyboard == .emailAddress ? .none : .words)
                .autocorrectionDisabled(keyboard == .emailAddress)
                .font(DSFont.body)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(titulo)
    }

    private func campoSenha(titulo: String, texto: Binding<String>) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "lock.fill")
                .foregroundStyle(DSColor.textSecondary)
                .frame(width: 24)
                .accessibilityHidden(true)
            SecureField(titulo, text: texto)
                .textContentType(viewModel.modo == .login ? .password : .newPassword)
                .font(DSFont.body)
        }
        .padding(DSSpacing.sm)
        .background(DSColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: DSSpacing.cornerMd))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(titulo)
    }
}
