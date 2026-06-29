import Foundation

enum ContentLanguage: String, Codable, CaseIterable, Identifiable {
    case ro
    case en
    case ru

    var id: String { rawValue }

    var label: String {
        rawValue.uppercased()
    }
}

enum MediaAssetKind: String, Codable {
    case photo
    case audio
    case text
}

enum PackageInstallState: String, Codable, CaseIterable {
    case notDownloaded
    case downloading
    case downloaded
    case readyOffline
    case updateAvailable
    case unavailableOffline
    case corrupted

    var title: String {
        switch self {
        case .notDownloaded: return "Скачать"
        case .downloading: return "Скачивается"
        case .downloaded: return "Скачан"
        case .readyOffline: return "Готов офлайн"
        case .updateAvailable: return "Есть обновление"
        case .unavailableOffline: return "Офлайн недоступен"
        case .corrupted: return "Поврежден"
        }
    }
}

enum LocationPermissionState: String, Codable {
    case notDetermined
    case authorizedWhenInUse
    case authorizedAlways
    case denied
    case restricted

    var isAuthorized: Bool {
        self == .authorizedWhenInUse || self == .authorizedAlways
    }
}

enum PreflightCheckState: String, Codable {
    case ready
    case warning
    case failed

    var title: String {
        switch self {
        case .ready: return "Готово"
        case .warning: return "Внимание"
        case .failed: return "Не готово"
        }
    }
}

enum FlightModeKind: String, Codable {
    case guided
    case freeFlight
}

enum GPSStatus: String, Codable {
    case unknown
    case active
    case limited
    case unavailable

    var title: String {
        switch self {
        case .unknown: return "ожидание"
        case .active: return "активен"
        case .limited: return "ограничен"
        case .unavailable: return "недоступен"
        }
    }
}

enum OfflineMapStatus: String, Codable {
    case missing
    case available
    case unavailableInSDK

    var title: String {
        switch self {
        case .missing: return "не загружена"
        case .available: return "доступна"
        case .unavailableInSDK: return "placeholder"
        }
    }
}

struct DownloadComponent: Identifiable, Hashable, Codable {
    let id: String
    let title: String
}

struct DownloadProgressSnapshot: Codable, Hashable {
    let packageID: String
    let currentStep: String
    let fractionCompleted: Double
    let completedComponents: [String]
    let totalComponents: Int
}

struct PreflightCheckItem: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let message: String
    let state: PreflightCheckState
}

struct OfflineAvailabilityReport: Hashable, Codable {
    let routeID: String?
    let packageID: String?
    let status: PackageInstallState
    let missingRequirements: [String]
    let mapStatus: OfflineMapStatus
}

struct MapPOISnapshot: Identifiable, Hashable {
    let id: String
    let title: String
    let coordinate: CoordinatePoint
    let isActive: Bool
}

struct MapRenderSnapshot: Hashable {
    let title: String
    let subtitle: String
    let visiblePOICount: Int
    let mapStatus: OfflineMapStatus
    let isMapConfigured: Bool
    let routeCoordinates: [CoordinatePoint]
    let pointsOfInterest: [MapPOISnapshot]
    let currentLocation: CoordinatePoint?
    let focusCoordinate: CoordinatePoint?
    let warningMessage: String?
}

struct AppSettings: Codable, Hashable {
    var onboardingCompleted: Bool
    var disclaimerAccepted: Bool
    var selectedAirportID: String?
    var selectedCountryCode: String?
    var contentLanguage: ContentLanguage
    var autoplayAudio: Bool
}

struct NearestAirportMatch: Hashable {
    let airport: Airport
    let distanceKilometers: Double
    let isSupported: Bool
}
