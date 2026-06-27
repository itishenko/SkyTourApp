import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        Group {
            switch appState.launchStage {
            case .loading:
                SkyTourScaffold(title: "SkyTour", subtitle: "Подготовка demo-контента") {
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(SkyTourTheme.accent)
                        Text("Загружаем маршруты, пакеты и стартовые настройки.")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 280)
                }
            case .onboarding:
                OnboardingView()
            case .disclaimer:
                LegalDisclaimerView()
            case .permissions:
                LocationPermissionView()
            case .airportSelection:
                AirportSelectionView()
            case .main:
                MainShellView()
            }
        }
        .task {
            await appState.bootstrapIfNeeded()
        }
    }
}

private struct MainShellView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        TabView(selection: $router.selectedTab) {
            HomeNavigationView()
                .tabItem {
                    Label("Главная", systemImage: "airplane.circle.fill")
                }
                .tag(AppTab.home)

            OfflineManagerView()
                .tabItem {
                    Label("Офлайн", systemImage: "square.and.arrow.down.fill")
                }
                .tag(AppTab.offline)

            SettingsView()
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(SkyTourTheme.accent)
    }
}

private struct HomeNavigationView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack(path: $router.homePath) {
            HomeView()
                .navigationDestination(for: HomeDestination.self) { destination in
                    destinationView(destination)
                }
        }
    }

    @ViewBuilder
    private func destinationView(_ destination: HomeDestination) -> some View {
        switch destination {
        case .airports:
            AirportSelectionView(allowsBackNavigation: true)
        case .routes:
            RouteListView()
        case .routeDetails(let routeID):
            RouteDetailsView(route: appState.route(id: routeID))
        case .packages:
            PackageListView()
        case .packageDetails(let packageID):
            PackageDetailsView(routePackage: appState.routePackage(id: packageID))
        case .preflight(let routeID):
            PreflightChecklistView(route: appState.route(id: routeID))
        case .flight(let routeID):
            FlightMapView(route: appState.route(id: routeID))
        case .pointDetails(let poiID):
            PointDetailsView(poi: appState.poi(id: poiID))
        case .freeFlight:
            FreeFlightView()
        }
    }
}

