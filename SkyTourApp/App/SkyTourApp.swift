import SwiftUI

@main
struct SkyTourApplication: App {
    private let container: DependencyContainer
    @StateObject private var appState: AppState
    @StateObject private var router = AppRouter()

    init() {
        let container = DependencyContainer.live()
        self.container = container
        _appState = StateObject(wrappedValue: AppState(container: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(router)
        }
    }
}

