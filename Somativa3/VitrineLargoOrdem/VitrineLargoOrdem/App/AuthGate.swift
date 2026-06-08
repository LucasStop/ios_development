import SwiftUI

/// Roteador de mais alto nível — decide entre LoginView e RootTabView
/// baseado no estado de autenticação. Observa o `AuthViewModel`
/// criado uma única vez no `App`.
struct AuthGate: View {
    @ObservedObject var authViewModel: AuthViewModel
    let dependencies: AppDependencies

    var body: some View {
        Group {
            if authViewModel.estaAutenticado {
                RootTabView(dependencies: dependencies, authViewModel: authViewModel)
                    .transition(.opacity)
            } else {
                LoginView(viewModel: authViewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.estaAutenticado)
    }
}
