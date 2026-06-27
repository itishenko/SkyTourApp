import Foundation
import UIKit

@MainActor
struct LocalContentRepository: ContentRepository {
    private let loader = BundleJSONLoader()

    func loadCountries() async throws -> [Country] {
        try loader.load("countries", as: [Country].self)
    }

    func loadAirports() async throws -> [Airport] {
        try loader.load("airports", as: [Airport].self)
    }

    func loadRoutes() async throws -> [Route] {
        try loader.load("routes", as: [Route].self)
    }

    func loadRoutePackages() async throws -> [RoutePackage] {
        try loader.load("route_packages", as: [RoutePackage].self)
    }
}

@MainActor
final class UserDefaultsPackageStateRepository: PackageStateRepository {
    private let defaults: UserDefaults
    private let storageKey = "skytour.package.states"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadPackageStates() async -> [String: PackageInstallState] {
        guard let data = defaults.data(forKey: storageKey) else {
            return [:]
        }

        return (try? JSONDecoder().decode([String: PackageInstallState].self, from: data)) ?? [:]
    }

    func savePackageState(packageID: String, state: PackageInstallState) async {
        var current = await loadPackageStates()
        current[packageID] = state
        let data = try? JSONEncoder().encode(current)
        defaults.set(data, forKey: storageKey)
    }

    func deletePackageState(packageID: String) async {
        var current = await loadPackageStates()
        current.removeValue(forKey: packageID)
        let data = try? JSONEncoder().encode(current)
        defaults.set(data, forKey: storageKey)
    }
}

@MainActor
final class UserDefaultsSettingsService: SettingsService {
    private let defaults: UserDefaults
    private let storageKey = "skytour.settings"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSettings() async -> AppSettings {
        guard let data = defaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings(
                onboardingCompleted: false,
                disclaimerAccepted: false,
                selectedAirportID: nil,
                selectedCountryCode: "MD",
                contentLanguage: .ro,
                autoplayAudio: true
            )
        }

        return decoded
    }

    func saveSettings(_ settings: AppSettings) async {
        let data = try? JSONEncoder().encode(settings)
        defaults.set(data, forKey: storageKey)
    }

    func appVersionDescription() -> String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String ?? "1"
        return "v\(version) (\(build))"
    }
}
