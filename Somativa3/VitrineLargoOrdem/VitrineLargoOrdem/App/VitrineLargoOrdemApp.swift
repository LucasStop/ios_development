import SwiftUI
import SwiftData

@main
struct VitrineLargoOrdemApp: App {

    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootTabView(dependencies: dependencies)
                .modelContainer(dependencies.modelContainer)
                .environmentObject(dependencies)
        }
    }
}
