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

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        let context = modelContainer.mainContext
        self.productRepository = LocalProductRepository(context: context)
        self.favoriteRepository = LocalFavoriteRepository(context: context)
        self.cartRepository = LocalCartRepository(context: context)
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
}
