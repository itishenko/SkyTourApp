import Foundation

@MainActor
struct DependencyContainer {
    let contentRepository: ContentRepository
    let packageStateRepository: PackageStateRepository
    let settingsService: SettingsService
    let locationService: LocationService
    let mapService: MapService
    let packageDownloadService: PackageDownloadService
    let offlineAvailabilityService: OfflineAvailabilityService
    let poiTriggerEngine: POITriggerEngine
    let audioGuideService: AudioGuideService

    let loadCountriesUseCase: LoadCountriesUseCase
    let loadAirportsUseCase: LoadAirportsUseCase
    let loadRoutesUseCase: LoadRoutesUseCase
    let loadRoutePackagesUseCase: LoadRoutePackagesUseCase
    let detectNearestAirportUseCase: DetectNearestAirportUseCase
    let downloadRoutePackageUseCase: DownloadRoutePackageUseCase
    let verifyRoutePackageUseCase: VerifyRoutePackageUseCase
    let checkOfflineAvailabilityUseCase: CheckOfflineAvailabilityUseCase
    let runPreflightChecklistUseCase: RunPreflightChecklistUseCase
    let startFlightSessionUseCase: StartFlightSessionUseCase
    let detectActivePOIUseCase: DetectActivePOIUseCase

    static func live() -> DependencyContainer {
        let contentRepository = LocalContentRepository()
        let packageStateRepository = UserDefaultsPackageStateRepository()
        let settingsService = UserDefaultsSettingsService()
        let locationService = CoreLocationService()
        let mapService = MapboxMapService()
        let packageDownloadService = MockPackageDownloadService()
        let offlineAvailabilityService = DefaultOfflineAvailabilityService()
        let poiTriggerEngine = MockPOITriggerEngine()
        let audioGuideService = MockAudioGuideService()

        let loadCountriesUseCase = LoadCountriesUseCase(repository: contentRepository)
        let loadAirportsUseCase = LoadAirportsUseCase(repository: contentRepository)
        let loadRoutesUseCase = LoadRoutesUseCase(repository: contentRepository)
        let loadRoutePackagesUseCase = LoadRoutePackagesUseCase(repository: contentRepository)
        let detectNearestAirportUseCase = DetectNearestAirportUseCase(locationService: locationService)
        let downloadRoutePackageUseCase = DownloadRoutePackageUseCase(
            downloadService: packageDownloadService,
            stateRepository: packageStateRepository
        )
        let verifyRoutePackageUseCase = VerifyRoutePackageUseCase(stateRepository: packageStateRepository)
        let checkOfflineAvailabilityUseCase = CheckOfflineAvailabilityUseCase(service: offlineAvailabilityService)
        let runPreflightChecklistUseCase = RunPreflightChecklistUseCase(
            availabilityUseCase: checkOfflineAvailabilityUseCase
        )
        let startFlightSessionUseCase = StartFlightSessionUseCase(poiTriggerEngine: poiTriggerEngine)
        let detectActivePOIUseCase = DetectActivePOIUseCase(triggerEngine: poiTriggerEngine)

        return DependencyContainer(
            contentRepository: contentRepository,
            packageStateRepository: packageStateRepository,
            settingsService: settingsService,
            locationService: locationService,
            mapService: mapService,
            packageDownloadService: packageDownloadService,
            offlineAvailabilityService: offlineAvailabilityService,
            poiTriggerEngine: poiTriggerEngine,
            audioGuideService: audioGuideService,
            loadCountriesUseCase: loadCountriesUseCase,
            loadAirportsUseCase: loadAirportsUseCase,
            loadRoutesUseCase: loadRoutesUseCase,
            loadRoutePackagesUseCase: loadRoutePackagesUseCase,
            detectNearestAirportUseCase: detectNearestAirportUseCase,
            downloadRoutePackageUseCase: downloadRoutePackageUseCase,
            verifyRoutePackageUseCase: verifyRoutePackageUseCase,
            checkOfflineAvailabilityUseCase: checkOfflineAvailabilityUseCase,
            runPreflightChecklistUseCase: runPreflightChecklistUseCase,
            startFlightSessionUseCase: startFlightSessionUseCase,
            detectActivePOIUseCase: detectActivePOIUseCase
        )
    }
}
