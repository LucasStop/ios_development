import SwiftUI

struct EnderecoFormView: View {
    @ObservedObject var viewModel: EnderecoFormViewModel
    @Environment(\.dismiss) private var dismiss

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
                        TextField("00000-000", text: $viewModel.cep)
                            .keyboardType(.numberPad)
                            .textContentType(.postalCode)
                            .accessibilityLabel("CEP")

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
                        .disabled(viewModel.cep.filter { $0.isNumber }.count != 8 || viewModel.buscandoCEP)
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
                        TextField("Número", text: $viewModel.numero)
                            .keyboardType(.numbersAndPunctuation)
                            .frame(maxWidth: 100)
                            .accessibilityLabel("Número")
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
                        TextField("UF", text: $viewModel.uf)
                            .textContentType(.addressState)
                            .frame(maxWidth: 70)
                            .autocapitalization(.allCharacters)
                            .accessibilityLabel("UF")
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
