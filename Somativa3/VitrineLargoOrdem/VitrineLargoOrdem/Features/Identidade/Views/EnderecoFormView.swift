import SwiftUI

struct EnderecoFormView: View {
    @ObservedObject var viewModel: EnderecoFormViewModel
    @Environment(\.dismiss) private var dismiss

    /// Binding sanitizado para o campo CEP: remove qualquer caractere
    /// não-numérico (cobre paste, dictation e teclado físico que ignoram
    /// `keyboardType(.numberPad)`) e trunca em 8 dígitos.
    private var bindingCEPApenasNumeros: Binding<String> {
        Binding(
            get: { viewModel.cep },
            set: { novoValor in
                let apenasDigitos = novoValor.filter(\.isNumber)
                viewModel.cep = String(apenasDigitos.prefix(8))
            }
        )
    }

    /// Binding sanitizado para o campo Número do endereço — também
    /// só aceita dígitos (e bloqueia paste com letras).
    private var bindingNumeroApenasDigitos: Binding<String> {
        Binding(
            get: { viewModel.numero },
            set: { viewModel.numero = String($0.filter(\.isNumber).prefix(8)) }
        )
    }

    /// Binding sanitizado para a UF — aceita apenas duas letras maiúsculas.
    private var bindingUFDuasLetras: Binding<String> {
        Binding(
            get: { viewModel.uf },
            set: { novoValor in
                let apenasLetras = novoValor.filter(\.isLetter).uppercased()
                viewModel.uf = String(apenasLetras.prefix(2))
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Identificação") {
                    TextField("Apelido (ex.: Casa, Trabalho)", text: $viewModel.apelido)
                        .accessibilityLabel("Apelido do endereço")
                    Toggle("Tornar padrão", isOn: $viewModel.ehPadrao)
                        .accessibilityHint("Endereços padrão são pré-selecionados no checkout.")
                }

                Section("CEP") {
                    HStack(spacing: DSSpacing.sm) {
                        TextField("00000-000", text: bindingCEPApenasNumeros)
                            .keyboardType(.numberPad)
                            .textContentType(.postalCode)
                            .accessibilityLabel("CEP")
                            .accessibilityHint("Apenas números. Máximo 8 dígitos.")

                        Button {
                            Task { await viewModel.buscarCEP() }
                        } label: {
                            if viewModel.buscandoCEP {
                                ProgressView()
                            } else {
                                Label("Buscar", systemImage: "magnifyingglass")
                                    .labelStyle(.titleAndIcon)
                            }
                        }
                        .frame(minWidth: DSSpacing.touchTargetMin, minHeight: DSSpacing.touchTargetMin)
                        .disabled(viewModel.cep.count != 8 || viewModel.buscandoCEP)
                        .accessibilityHint("Consulta o endereço associado ao CEP digitado.")
                    }
                    if let erro = viewModel.erro {
                        Text(erro.errorDescription ?? "")
                            .font(DSFont.metadata)
                            .foregroundStyle(DSColor.danger)
                    }
                }

                Section("Endereço") {
                    TextField("Logradouro", text: $viewModel.logradouro)
                        .textContentType(.streetAddressLine1)
                        .accessibilityLabel("Logradouro")
                    HStack {
                        TextField("Número", text: bindingNumeroApenasDigitos)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: 100)
                            .accessibilityLabel("Número")
                            .accessibilityHint("Apenas números do endereço.")
                        TextField("Complemento (opcional)", text: $viewModel.complemento)
                            .accessibilityLabel("Complemento")
                    }
                    TextField("Bairro", text: $viewModel.bairro)
                        .textContentType(.sublocality)
                        .accessibilityLabel("Bairro")
                    HStack {
                        TextField("Cidade", text: $viewModel.cidade)
                            .textContentType(.addressCity)
                            .accessibilityLabel("Cidade")
                        TextField("UF", text: bindingUFDuasLetras)
                            .textContentType(.addressState)
                            .frame(maxWidth: 70)
                            .autocapitalization(.allCharacters)
                            .accessibilityLabel("UF")
                            .accessibilityHint("Sigla do estado com duas letras.")
                    }
                }

                Section {
                    Button {
                        viewModel.salvar()
                        dismiss()
                    } label: {
                        Text(viewModel.enderecoExistente == nil ? "Cadastrar endereço" : "Salvar alterações")
                            .frame(maxWidth: .infinity, minHeight: DSSpacing.touchTargetMin)
                            .accessibilityAddTraits(.isButton)
                    }
                    .disabled(!viewModel.formularioValido)
                    .accessibilityHint("Persiste o endereço para uso no checkout.")
                }
            }
            .navigationTitle(viewModel.modo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
    }
}
