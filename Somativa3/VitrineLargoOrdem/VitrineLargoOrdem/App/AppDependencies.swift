import Foundation
import SwiftData
import SwiftUI

/// Composição raiz da app — instancia o ModelContainer e os repositories.
///
/// Fica em `App/` por ser o ponto onde decisões globais de DI vivem.
/// Quando V1 trouxer backend, esta é a fronteira que ganha um
/// `RemoteProductRepository` para alternar via `AppEnvironment`.
@MainActor
final class AppDependencies: ObservableObject {

    let modelContainer: ModelContainer
    let productRepository: ProductRepository
    let favoriteRepository: FavoriteRepository
    let cartRepository: CartRepository
    let authService: AuthService
    let addressRepository: AddressRepository
    let cepService: CEPService
    let orderRepository: OrderRepository

    /// Cliente Supabase compartilhado, criado uma única vez por sessão.
    /// `nil` quando `AppConfig.useSupabase == false` (UITests/CI).
    let supabaseClient: SupabaseClient?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = modelContainer.mainContext
        self.productRepository = LocalProductRepository(context: context)
        self.favoriteRepository = LocalFavoriteRepository(context: context)
        self.cartRepository = LocalCartRepository(context: context)
        self.addressRepository = LocalAddressRepository(context: context)
        self.cepService = ViaCEPService()
        self.orderRepository = LocalOrderRepository(context: context)

        if AppConfig.useSupabase {
            let client = SupabaseClient(configuracao: .init(
                url: AppConfig.supabaseURL,
                publishableKey: AppConfig.supabaseKey
            ))
            self.supabaseClient = client
            self.authService = SupabaseAuthService(client: client, context: context)
        } else {
            self.supabaseClient = nil
            self.authService = LocalAuthService(context: context)
        }
    }

    /// Inicializador padrão usado pelo App — usa o container persistente compartilhado.
    convenience init() {
        self.init(modelContainer: PersistenceController.shared)
    }

    func makeVitrineViewModel() -> VitrineViewModel {
        VitrineViewModel(
            productRepository: productRepository,
            favoriteRepository: favoriteRepository
        )
    }

    func makeCarrinhoViewModel() -> CarrinhoViewModel {
        CarrinhoViewModel(cartRepository: cartRepository)
    }

    func makeFavoritosViewModel() -> FavoritosViewModel {
        FavoritosViewModel(
            productRepository: productRepository,
            favoriteRepository: favoriteRepository
        )
    }

    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authService: authService)
    }

    func makePerfilViewModel(usuario: Usuario) -> PerfilViewModel {
        PerfilViewModel(usuario: usuario)
    }

    func makeEnderecosViewModel(usuarioId: UUID) -> EnderecosViewModel {
        EnderecosViewModel(repository: addressRepository, usuarioId: usuarioId)
    }

    func makeEnderecoFormViewModel(usuarioId: UUID, editando: Endereco? = nil) -> EnderecoFormViewModel {
        EnderecoFormViewModel(
            cepService: cepService,
            addressRepository: addressRepository,
            usuarioId: usuarioId,
            editando: editando
        )
    }

    func makePedidosViewModel(usuarioId: UUID) -> PedidosViewModel {
        PedidosViewModel(orderRepository: orderRepository, usuarioId: usuarioId)
    }

    func makeCheckoutViewModel(carrinhoViewModel: CarrinhoViewModel, usuarioId: UUID) -> CheckoutViewModel {
        CheckoutViewModel(
            carrinhoViewModel: carrinhoViewModel,
            addressRepository: addressRepository,
            orderRepository: orderRepository,
            usuarioId: usuarioId
        )
    }

    func makeAdminPedidosViewModel() -> AdminPedidosViewModel {
        AdminPedidosViewModel(
            context: modelContainer.mainContext,
            orderRepository: orderRepository
        )
    }
}
