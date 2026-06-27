import Foundation

struct PackageManifest: Codable, Hashable {
    let schemaVersion: String
    let requiredFiles: [String]
    let checksums: [String: String]
    let mapRegionID: String?
    let includesOfflineMap: Bool
}

struct RoutePackage: Identifiable, Codable, Hashable {
    let id: String
    let airportID: String
    let title: String
    let summary: String
    let routeIDs: [String]
    let poiCount: Int
    let sizeMB: Int
    let languages: [ContentLanguage]
    let version: String
    let updatedAt: Date
    let manifest: PackageManifest
}

