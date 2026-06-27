import Foundation

@MainActor
protocol ContentRepository {
    func loadCountries() async throws -> [Country]
    func loadAirports() async throws -> [Airport]
    func loadRoutes() async throws -> [Route]
    func loadRoutePackages() async throws -> [RoutePackage]
}

@MainActor
protocol PackageStateRepository {
    func loadPackageStates() async -> [String: PackageInstallState]
    func savePackageState(packageID: String, state: PackageInstallState) async
    func deletePackageState(packageID: String) async
}
