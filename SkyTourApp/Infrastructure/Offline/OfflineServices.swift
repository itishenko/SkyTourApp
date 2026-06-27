import Foundation

@MainActor
struct DefaultOfflineAvailabilityService: OfflineAvailabilityService {
    func availability(
        for route: Route?,
        selectedPackage: RoutePackage?,
        installedPackageIDs: Set<String>
    ) async -> OfflineAvailabilityReport {
        let packageID = selectedPackage?.id ?? route?.packageID
        let isInstalled = packageID.map(installedPackageIDs.contains) ?? false

        let missingRequirements: [String]
        let status: PackageInstallState
        if isInstalled {
            status = .readyOffline
            missingRequirements = []
        } else {
            status = .notDownloaded
            missingRequirements = ["route data", "media", "offline map fallback"]
        }

        return OfflineAvailabilityReport(
            routeID: route?.id,
            packageID: packageID,
            status: status,
            missingRequirements: missingRequirements,
            mapStatus: isInstalled ? .available : .missing
        )
    }
}

@MainActor
struct MockPOITriggerEngine: POITriggerEngine {
    func activePOI(
        for session: FlightSession,
        route: Route?,
        availablePOI: [POI]
    ) -> POI? {
        if let currentPOIID = session.currentPOIID {
            return availablePOI.first(where: { $0.id == currentPOIID })
        }

        return route?.poi.first ?? availablePOI.first
    }
}
