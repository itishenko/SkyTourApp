import Foundation

@MainActor
struct LoadCountriesUseCase {
    let repository: ContentRepository

    func execute() async throws -> [Country] {
        try await repository.loadCountries()
    }
}

@MainActor
struct LoadAirportsUseCase {
    let repository: ContentRepository

    func execute() async throws -> [Airport] {
        try await repository.loadAirports()
    }
}

@MainActor
struct LoadRoutesUseCase {
    let repository: ContentRepository

    func execute() async throws -> [Route] {
        try await repository.loadRoutes()
    }
}

@MainActor
struct LoadRoutePackagesUseCase {
    let repository: ContentRepository

    func execute() async throws -> [RoutePackage] {
        try await repository.loadRoutePackages()
    }
}

@MainActor
struct DetectNearestAirportUseCase {
    let locationService: LocationService

    func execute(airports: [Airport]) async -> NearestAirportMatch? {
        guard let current = await locationService.currentLocation() else {
            return nil
        }

        let nearest = airports.min { lhs, rhs in
            distance(from: current, to: lhs) < distance(from: current, to: rhs)
        }

        guard let nearest else { return nil }

        return NearestAirportMatch(
            airport: nearest,
            distanceKilometers: distance(from: current, to: nearest),
            isSupported: nearest.isSupported
        )
    }

    private func distance(from current: CoordinatePoint, to airport: Airport) -> Double {
        let dx = current.latitude - airport.latitude
        let dy = current.longitude - airport.longitude
        return sqrt(dx * dx + dy * dy) * 111
    }
}

@MainActor
struct DownloadRoutePackageUseCase {
    let downloadService: PackageDownloadService
    let stateRepository: PackageStateRepository

    func execute(
        package: RoutePackage,
        progress: @escaping @MainActor (DownloadProgressSnapshot) -> Void
    ) async throws {
        await stateRepository.savePackageState(packageID: package.id, state: .downloading)
        try await downloadService.download(package: package, progress: progress)
        await stateRepository.savePackageState(packageID: package.id, state: .readyOffline)
    }
}

@MainActor
struct VerifyRoutePackageUseCase {
    let stateRepository: PackageStateRepository

    func execute(packageID: String) async -> PackageInstallState {
        let state = await stateRepository.loadPackageStates()[packageID] ?? .notDownloaded
        return state
    }
}

@MainActor
struct CheckOfflineAvailabilityUseCase {
    let service: OfflineAvailabilityService

    func execute(
        route: Route?,
        selectedPackage: RoutePackage?,
        installedPackageIDs: Set<String>
    ) async -> OfflineAvailabilityReport {
        await service.availability(
            for: route,
            selectedPackage: selectedPackage,
            installedPackageIDs: installedPackageIDs
        )
    }
}

@MainActor
struct RunPreflightChecklistUseCase {
    let availabilityUseCase: CheckOfflineAvailabilityUseCase

    func execute(
        selectedAirport: Airport?,
        route: Route?,
        selectedPackage: RoutePackage?,
        installedPackageIDs: Set<String>,
        permissionState: LocationPermissionState,
        gpsStatus: GPSStatus
    ) async -> [PreflightCheckItem] {
        let availability = await availabilityUseCase.execute(
            route: route,
            selectedPackage: selectedPackage,
            installedPackageIDs: installedPackageIDs
        )

        return [
            PreflightCheckItem(
                id: "airport",
                title: "Аэропорт выбран",
                message: selectedAirport?.name ?? "Выберите поддерживаемый аэропорт перед стартом.",
                state: selectedAirport == nil ? .failed : .ready
            ),
            PreflightCheckItem(
                id: "route",
                title: "Маршрут или свободный полет",
                message: route?.title ?? "Маршрут не выбран. Можно перейти в свободный полет только при готовом офлайн-пакете.",
                state: route == nil ? .warning : .ready
            ),
            PreflightCheckItem(
                id: "package",
                title: "Офлайн-пакет",
                message: availability.status.title,
                state: availability.status == .readyOffline ? .ready : .failed
            ),
            PreflightCheckItem(
                id: "map",
                title: "Оффлайн-карта / fallback",
                message: availability.mapStatus.title,
                state: availability.mapStatus == .missing ? .warning : .ready
            ),
            PreflightCheckItem(
                id: "gps",
                title: "GPS и доступ к геолокации",
                message: "\(gpsStatus.title), разрешение: \(permissionState.rawValue)",
                state: permissionState.isAuthorized ? .ready : .warning
            )
        ]
    }
}

@MainActor
struct StartFlightSessionUseCase {
    let poiTriggerEngine: POITriggerEngine

    func execute(airport: Airport, route: Route?, package: RoutePackage?, mode: FlightModeKind) -> FlightSession {
        let poi = route?.poi.first
        return FlightSession(
            id: UUID(),
            airportID: airport.id,
            routeID: route?.id,
            packageID: package?.id ?? route?.packageID,
            mode: mode,
            startedAt: .now,
            currentPOIID: poi?.id,
            nextPOIID: route?.poi.dropFirst().first?.id,
            completedPOIIDs: [],
            isDeviationDetected: false
        )
    }
}

@MainActor
struct DetectActivePOIUseCase {
    let triggerEngine: POITriggerEngine

    func execute(session: FlightSession, route: Route?, availablePOI: [POI]) -> POI? {
        triggerEngine.activePOI(for: session, route: route, availablePOI: availablePOI)
    }
}
