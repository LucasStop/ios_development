import SwiftUI

/// Raiz da interface — TabView com Vitrine, Favoritos e Carrinho.
///
/// Cada aba recebe seu ViewModel próprio (todos derivados do mesmo
/// AppDependencies) para isolar estado e ainda assim compartilhar a
/// camada de Repository abaixo.
struct RootTabView: View {
    @EnvironmentObject var dependencies: AppDependencies
    @ObservedObject var authViewModel: AuthViewModel

    @StateObject private var vitrineViewModel: VitrineViewModel
    @StateObject private var carrinhoViewModel: CarrinhoViewModel
    @StateObject private var favoritosViewModel: FavoritosViewModel
    @StateObject private var perfilViewModel: PerfilViewModel
    @StateObject private var enderecosViewModel: EnderecosViewModel

    init(dependencies: AppDependencies, authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        let usuario = authViewModel.usuarioAtual ?? Usuario(email: "", nome: "Convidado", provedor: "convidado")
        _vitrineViewModel = StateObject(wrappedValue: dependencies.makeVitrineViewModel())
        _carrinhoViewModel = StateObject(wrappedValue: dependencies.makeCarrinhoViewModel())
        _favoritosViewModel = StateObject(wrappedValue: dependencies.makeFavoritosViewModel())
        _perfilViewModel = StateObject(wrappedValue: dependencies.makePerfilViewModel(usuario: usuario))
        _enderecosViewModel = StateObject(wrappedValue: dependencies.makeEnderecosViewModel(usuarioId: usuario.id))
    }

    var body: some View {
        TabView {
            VitrineView(
                viewModel: vitrineViewModel,
                carrinhoViewModel: carrinhoViewModel
            )
            .tabItem {
                Label("Vitrine", systemImage: "storefront.fill")
            }
            .accessibilityLabel("Aba Vitrine")

            FavoritosView(
                viewModel: favoritosViewModel,
                carrinhoViewModel: carrinhoViewModel,
                vitrineViewModel: vitrineViewModel
            )
            .tabItem {
                Label("Favoritos", systemImage: "heart.fill")
            }
            .accessibilityLabel("Aba Favoritos")
            .onAppear { favoritosViewModel.recarregar() }

            CarrinhoView(viewModel: carrinhoViewModel)
                .tabItem {
                    Label("Carrinho", systemImage: "cart.fill")
                }
                .accessibilityLabel("Aba Carrinho")
                .badge(carrinhoViewModel.totalDeItens)
                .onAppear { carrinhoViewModel.recarregar() }

            PerfilView(
                perfilViewModel: perfilViewModel,
                enderecosViewModel: enderecosViewModel,
                authViewModel: authViewModel,
                dependencies: dependencies
            )
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
            .accessibilityLabel("Aba Perfil")
        }
        .tint(DSColor.primary)
    }
}
