import SwiftUI
import SwiftData

@main
struct VitrineLargoOrdemApp: App {

    @StateObject private var dependencies = AppDependencies()
    @AppStorage("jaViuOnboarding") private var jaViuOnboarding: Bool = false

    init() {
        // Permite que UITests pulem o onboarding sem alterar o estado real do app.
        if ProcessInfo.processInfo.environment["SKIP_ONBOARDING"] == "1" {
            UserDefaults.standard.set(true, forKey: "jaViuOnboarding")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if jaViuOnboarding {
                    RootTabView(dependencies: dependencies)
                } else {
                    OnboardingView(jaViu: $jaViuOnboarding)
                }
            }
            .modelContainer(dependencies.modelContainer)
            .environmentObject(dependencies)
        }
    }
}
