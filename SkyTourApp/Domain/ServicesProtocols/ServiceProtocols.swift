import Foundation

@MainActor
protocol SettingsService {
    func loadSettings() async -> AppSettings
    func saveSettings(_ settings: AppSettings) async
    func appVersionDescription() -> String
}

@MainActor
protocol LocationService {
    func authorizationState() async -> LocationPermissionState
    func requestWhenInUseAuthorization() async -> LocationPermissionState
    func denyAuthorization() async -> LocationPermissionState
    func currentLocation() async -> CoordinatePoint?
    func locationUpdates() -> AsyncStream<CoordinatePoint?>
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func openSystemSettings()
}

@MainActor
protocol MapService {
    func renderSnapshot(
        route: Route?,
        availablePOI: [POI],
        activePOI: POI?,
        currentLocation: CoordinatePoint?,
        gpsStatus: GPSStatus
    ) -> MapRenderSnapshot
}

@MainActor
protocol PackageDownloadService {
    func download(
        package: RoutePackage,
        progress: @escaping @MainActor (DownloadProgressSnapshot) -> Void
    ) async throws
}

@MainActor
protocol OfflineAvailabilityService {
    func availability(
        for route: Route?,
        selectedPackage: RoutePackage?,
        installedPackageIDs: Set<String>
    ) async -> OfflineAvailabilityReport
}

@MainActor
protocol POITriggerEngine {
    func activePOI(
        for session: FlightSession,
        route: Route?,
        availablePOI: [POI]
    ) -> POI?
}

@MainActor
protocol AudioGuideService {
    func play(_ poi: POI) async
    func pause() async
    func stop() async
}
