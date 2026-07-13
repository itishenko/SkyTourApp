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

        let isRouteDownloaded = availability.status == .readyOffline
        let hasPointsOfInterest = !(route?.poi.isEmpty ?? true)
        let hasAudioForRoute = route?.poi.contains { $0.audioAsset != nil } ?? false
        let isGPSActive = permissionState.isAuthorized && (gpsStatus == .active || gpsStatus == .limited)
        let isOfflineModeReady = selectedAirport != nil && permissionState.isAuthorized

        return [
            PreflightCheckItem(
                id: "routeDownloaded",
                title: "Маршрут скачан",
                message: isRouteDownloaded ? "Офлайн-пакет маршрута доступен на устройстве." : "Скачайте офлайн-пакет маршрута перед стартом.",
                state: isRouteDownloaded ? .ready : .warning
            ),
            PreflightCheckItem(
                id: "pointsDownloaded",
                title: "Точки интереса скачаны",
                message: isRouteDownloaded && hasPointsOfInterest ? "POI маршрута доступны офлайн." : "Точки маршрута станут доступны после загрузки пакета.",
                state: isRouteDownloaded && hasPointsOfInterest ? .ready : .warning
            ),
            PreflightCheckItem(
                id: "audioAvailable",
                title: "Аудио доступно",
                message: isRouteDownloaded && hasAudioForRoute ? "Аудиогид подготовлен для офлайн-воспроизведения." : "Аудио появится после загрузки полного офлайн-пакета.",
                state: isRouteDownloaded && hasAudioForRoute ? .ready : .warning
            ),
            PreflightCheckItem(
                id: "gpsActive",
                title: "GPS активен",
                message: isGPSActive ? "Геолокация активна." : "Для старта нужен активный GPS.",
                state: isGPSActive ? .ready : .warning
            ),
            PreflightCheckItem(
                id: "offlineModeReady",
                title: "Офлайн-режим готов",
                message: isOfflineModeReady ? "Можно переходить к офлайн-сценарию." : "Разрешите геолокацию и выберите аэропорт для офлайн-режима.",
                state: isOfflineModeReady ? .ready : .warning
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
