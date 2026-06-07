import SwiftUI
import SwiftData

@main
struct VitrineLargoOrdemApp: App {

    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            VitrineView(viewModel: dependencies.makeVitrineViewModel())
                .modelContainer(dependencies.modelContainer)
                .environmentObject(dependencies)
        }
    }
}
