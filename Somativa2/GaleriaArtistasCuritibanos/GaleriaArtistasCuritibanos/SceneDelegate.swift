import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let nav = UINavigationController(rootViewController: GaleriaViewController())
        nav.navigationBar.prefersLargeTitles = true

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}
