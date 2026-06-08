import SwiftUI
import SwiftData

@main
struct VitrineLargoOrdemApp: App {

    @StateObject private var dependencies: AppDependencies
    @StateObject private var authViewModel: AuthViewModel
    @AppStorage("jaViuOnboarding") private var jaViuOnboarding: Bool = false

    init() {
        // Permite que UITests pulem o onboarding e/ou auth sem alterar o estado real do app.
        if ProcessInfo.processInfo.environment["SKIP_ONBOARDING"] == "1" {
            UserDefaults.standard.set(true, forKey: "jaViuOnboarding")
        }

        let deps = AppDependencies()
        _dependencies = StateObject(wrappedValue: deps)
        _authViewModel = StateObject(wrappedValue: deps.makeAuthViewModel())

        // Auto-login para UITests — pula tela de login.
        if ProcessInfo.processInfo.environment["AUTO_LOGIN"] == "1" {
            deps.makeAuthViewModel().entrarComoConvidado()
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if jaViuOnboarding {
                    AuthGate(authViewModel: authViewModel, dependencies: dependencies)
                } else {
                    OnboardingView(jaViu: $jaViuOnboarding)
                }
            }
            .modelContainer(dependencies.modelContainer)
            .environmentObject(dependencies)
        }
    }
}
