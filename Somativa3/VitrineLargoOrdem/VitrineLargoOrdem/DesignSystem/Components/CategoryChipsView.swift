import SwiftUI

/// Carrossel horizontal de chips de categoria para filtragem rápida.
///
/// O chip "Todas" sempre aparece como primeiro, permitindo limpar
/// o filtro sem digitar na busca. Categorias chegam ordenadas
/// alfabeticamente pela ViewModel.
struct CategoryChipsView: View {
    let categorias: [String]
    let selecionada: String?
    let onSelecionar: (String?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.xs) {
                chip(rotulo: "Todas",
                     icone: "square.grid.2x2",
                     ativo: selecionada == nil) {
                    onSelecionar(nil)
                }

                ForEach(categorias, id: \.self) { categoria in
                    chip(rotulo: categoria,
                         icone: icone(para: categoria),
                         ativo: selecionada == categoria) {
                        onSelecionar(categoria)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.xs)
        }
        .accessibilityLabel("Filtro por categoria")
        .accessibilityHint("Arraste para os lados e toque numa categoria para filtrar produtos.")
    }

    private func chip(rotulo: String, icone: String, ativo: Bool, acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            HStack(spacing: DSSpacing.xxs) {
                Image(systemName: icone)
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
                Text(rotulo)
                    .font(DSFont.metadata.weight(.medium))
            }
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xs)
            .frame(minHeight: DSSpacing.touchTargetMin)
            .background(ativo ? DSColor.primary : DSColor.surface)
            .foregroundStyle(ativo ? DSColor.textOnAccent : DSColor.textPrimary)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(DSColor.border, lineWidth: ativo ? 0 : 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(ativo ? "\(rotulo), selecionado" : rotulo)
        .accessibilityHint(ativo ? "Toque para limpar o filtro." : "Toque para filtrar por \(rotulo).")
        .accessibilityAddTraits(.isButton)
    }

    /// Mapeia categorias para SF Symbols coerentes.
    private func icone(para categoria: String) -> String {
        switch categoria.lowercased() {
        case "madeira": return "leaf.fill"
        case "comidas": return "fork.knife"
        case "arte": return "paintbrush.fill"
        case "vestuário", "vestuario": return "tshirt.fill"
        case "antiguidades": return "clock.fill"
        case "acessórios", "acessorios": return "sparkles"
        case "beleza": return "bubbles.and.sparkles.fill"
        default: return "tag.fill"
        }
    }
}
