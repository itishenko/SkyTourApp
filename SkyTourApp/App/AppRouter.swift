import SwiftUI

enum AppTab: Hashable {
    case home
    case offline
    case settings
}

enum HomeDestination: Hashable {
    case airports
    case routes
    case routeDetails(String)
    case packages
    case packageDetails(String)
    case preflight(String?)
    case flight(String?)
    case pointDetails(String)
    case freeFlight
}

@MainActor
final class AppRouter: ObservableObject {
    @Published var selectedTab: AppTab = .home
    @Published var homePath = NavigationPath()

    func push(_ destination: HomeDestination) {
        homePath.append(destination)
    }

    func popToRoot() {
        homePath = NavigationPath()
    }
}

