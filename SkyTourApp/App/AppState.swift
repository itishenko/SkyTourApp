import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    enum LaunchStage {
        case loading
        case onboarding
        case disclaimer
        case permissions
        case airportSelection
        case main
    }

    @Published private(set) var isBootstrapped = false
    @Published var onboardingCompleted = false
    @Published var disclaimerAccepted = false
    @Published var locationPermissionState: LocationPermissionState = .notDetermined
    @Published var gpsStatus: GPSStatus = .unknown
    @Published var selectedCountry: Country?
    @Published var selectedAirport: Airport?
    @Published var selectedRoute: Route?
    @Published var selectedPackage: RoutePackage?
    @Published var contentLanguage: ContentLanguage = .ro
    @Published var autoplayAudio = true
    @Published var nearestAirportMatch: NearestAirportMatch?
    @Published var countries: [Country] = []
    @Published var airports: [Airport] = []
    @Published var routes: [Route] = []
    @Published var routePackages: [RoutePackage] = []
    @Published var packageStates: [String: PackageInstallState] = [:]
    @Published var downloadProgress: [String: DownloadProgressSnapshot] = [:]
    @Published var activeFlightSession: FlightSession?
    @Published var activePOI: POI?
    @Published var manualAirportSelectionRequested = false
    @Published var lastErrorMessage: String?

    let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    var launchStage: LaunchStage {
        guard isBootstrapped else { return .loading }
        if !onboardingCompleted { return .onboarding }
        if !disclaimerAccepted { return .disclaimer }
        if !locationPermissionState.isAuthorized && !manualAirportSelectionRequested {
            return .permissions
        }
        if selectedAirport == nil {
            return .airportSelection
        }
        return .main
    }

    var installedPackageIDs: Set<String> {
        Set(
            packageStates
                .filter { $0.value == .readyOffline || $0.value == .downloaded }
                .map(\.key)
        )
    }

    func bootstrapIfNeeded() async {
        guard !isBootstrapped else { return }

        do {
            let settings = await container.settingsService.loadSettings()
            let loadedCountries = try await container.loadCountriesUseCase.execute()
            let loadedAirports = try await container.loadAirportsUseCase.execute()
            let loadedRoutes = try await container.loadRoutesUseCase.execute()
            let loadedPackages = try await container.loadRoutePackagesUseCase.execute()
            let storedPackageStates = await container.packageStateRepository.loadPackageStates()
            let permissionState = await container.locationService.authorizationState()

            self.countries = loadedCountries
            self.airports = loadedAirports
            self.routes = loadedRoutes
            self.routePackages = loadedPackages
            self.packageStates = storedPackageStates
            self.onboardingCompleted = settings.onboardingCompleted
            self.disclaimerAccepted = settings.disclaimerAccepted
            self.contentLanguage = settings.contentLanguage
            self.autoplayAudio = settings.autoplayAudio
            self.locationPermissionState = permissionState
            self.gpsStatus = permissionState.isAuthorized ? .active : .limited
            self.selectedCountry = loadedCountries.first(where: { $0.code == settings.selectedCountryCode }) ?? loadedCountries.first
            self.selectedAirport = loadedAirports.first(where: { $0.id == settings.selectedAirportID })

            if let selectedAirport {
                self.selectedRoute = routes(for: selectedAirport).first
                self.selectedPackage = routePackage(id: self.selectedRoute?.packageID)
            }

            if permissionState.isAuthorized && self.selectedAirport == nil {
                self.nearestAirportMatch = await container.detectNearestAirportUseCase.execute(airports: loadedAirports)
            }

            autoSelectAirportIfNeeded()
            self.isBootstrapped = true
        } catch {
            self.lastErrorMessage = error.localizedDescription
            self.isBootstrapped = true
        }
    }

    func completeOnboarding() {
        onboardingCompleted = true
        persistSettings()
    }

    func acceptDisclaimer() {
        disclaimerAccepted = true
        persistSettings()
    }

    func requestLocationAccess() async {
        locationPermissionState = await container.locationService.requestWhenInUseAuthorization()
        gpsStatus = locationPermissionState.isAuthorized ? .active : .limited
        nearestAirportMatch = await container.detectNearestAirportUseCase.execute(airports: airports)
        autoSelectAirportIfNeeded()
    }

    func denyLocationAccess() async {
        locationPermissionState = await container.locationService.denyAuthorization()
        gpsStatus = .unavailable
        autoSelectAirportIfNeeded()
    }

    func openSystemSettings() {
        container.locationService.openSystemSettings()
    }

    func requestManualAirportSelection() {
        manualAirportSelectionRequested = true
    }

    func confirmNearestAirport() {
        guard let airport = nearestAirportMatch?.airport else { return }
        selectAirport(airport)
    }

    func selectAirport(_ airport: Airport) {
        selectedAirport = airport
        selectedCountry = countries.first(where: { $0.code == airport.countryCode })
        selectedRoute = routes(for: airport).first
        selectedPackage = selectedRoute.flatMap { routePackage(id: $0.packageID) }
        manualAirportSelectionRequested = false
        persistSettings()
    }

    func selectRoute(_ route: Route) {
        selectedRoute = route
        selectedPackage = routePackage(id: route.packageID)
    }

    func selectPackage(_ package: RoutePackage) {
        selectedPackage = package
    }

    func route(id: String?) -> Route? {
        guard let id else { return nil }
        return routes.first(where: { $0.id == id })
    }

    func routePackage(id: String?) -> RoutePackage? {
        guard let id else { return nil }
        return routePackages.first(where: { $0.id == id })
    }

    func poi(id: String?) -> POI? {
        guard let id else { return nil }
        return routes.flatMap(\.poi).first(where: { $0.id == id })
    }

    func routes(for airport: Airport?) -> [Route] {
        guard let airport else { return [] }
        return routes.filter { airport.routeIDs.contains($0.id) }
    }

    func packages(for airport: Airport?) -> [RoutePackage] {
        guard let airport else { return [] }
        return routePackages.filter { airport.routePackageIDs.contains($0.id) }
    }

    func packageState(for package: RoutePackage) -> PackageInstallState {
        packageStates[package.id] ?? .notDownloaded
    }

    func downloadedRoutesCount(for airport: Airport?) -> Int {
        routes(for: airport).filter { installedPackageIDs.contains($0.packageID) }.count
    }

    func availablePOIForFreeFlight() -> [POI] {
        routes
            .filter { installedPackageIDs.contains($0.packageID) }
            .flatMap(\.poi)
    }

    func download(_ package: RoutePackage) async {
        packageStates[package.id] = .downloading
        lastErrorMessage = nil
        do {
            try await container.downloadRoutePackageUseCase.execute(package: package) { [weak self] progress in
                self?.downloadProgress[package.id] = progress
            }
            packageStates[package.id] = .readyOffline
            downloadProgress[package.id] = nil
        } catch {
            packageStates[package.id] = .corrupted
            lastErrorMessage = error.localizedDescription
        }
    }

    func remove(_ package: RoutePackage) async {
        packageStates.removeValue(forKey: package.id)
        downloadProgress.removeValue(forKey: package.id)
        await container.packageStateRepository.deletePackageState(packageID: package.id)
    }

    func makePreflightChecklist(for route: Route?) async -> [PreflightCheckItem] {
        let package = route.flatMap { routePackage(id: $0.packageID) } ?? selectedPackage
        return await container.runPreflightChecklistUseCase.execute(
            selectedAirport: selectedAirport,
            route: route,
            selectedPackage: package,
            installedPackageIDs: installedPackageIDs,
            permissionState: locationPermissionState,
            gpsStatus: gpsStatus
        )
    }

    func startFlight(route: Route?, mode: FlightModeKind) async -> FlightSession? {
        guard let airport = selectedAirport else { return nil }
        let package = route.flatMap { routePackage(id: $0.packageID) } ?? selectedPackage
        let session = container.startFlightSessionUseCase.execute(
            airport: airport,
            route: route,
            package: package,
            mode: mode
        )
        activeFlightSession = session
        let availablePOI = route?.poi ?? availablePOIForFreeFlight()
        let poi = container.detectActivePOIUseCase.execute(
            session: session,
            route: route,
            availablePOI: availablePOI
        )
        activePOI = poi
        if autoplayAudio, let poi {
            await container.audioGuideService.play(poi)
        }
        return session
    }

    func stopFlight() async {
        activeFlightSession = nil
        activePOI = nil
        await container.audioGuideService.stop()
    }

    func playPOI(_ poi: POI) async {
        activePOI = poi
        await container.audioGuideService.play(poi)
    }

    func pauseAudio() async {
        await container.audioGuideService.pause()
    }

    func mapSnapshot(for route: Route?) -> MapRenderSnapshot {
        container.mapService.renderSnapshot(route: route, activePOI: activePOI, gpsStatus: gpsStatus)
    }

    func updateContentLanguage(_ language: ContentLanguage) {
        contentLanguage = language
        persistSettings()
    }

    func updateAutoplayAudio(_ value: Bool) {
        autoplayAudio = value
        persistSettings()
    }

    func appVersionDescription() -> String {
        container.settingsService.appVersionDescription()
    }

    private func autoSelectAirportIfNeeded() {
        guard selectedAirport == nil else { return }

        if let nearestAirport = nearestAirportMatch?.airport, nearestAirport.isSupported {
            selectAirport(nearestAirport)
            return
        }

        if let fallbackAirport = airports.first(where: \.isSupported) ?? airports.first {
            selectAirport(fallbackAirport)
        }
    }

    private func persistSettings() {
        let settings = AppSettings(
            onboardingCompleted: onboardingCompleted,
            disclaimerAccepted: disclaimerAccepted,
            selectedAirportID: selectedAirport?.id,
            selectedCountryCode: selectedCountry?.code,
            contentLanguage: contentLanguage,
            autoplayAudio: autoplayAudio
        )
        Task {
            await container.settingsService.saveSettings(settings)
        }
    }
}
