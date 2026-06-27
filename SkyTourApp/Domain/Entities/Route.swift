import Foundation

struct CoordinatePoint: Identifiable, Codable, Hashable {
    var id: String { "\(latitude)-\(longitude)" }
    let latitude: Double
    let longitude: Double
}

struct MediaAsset: Identifiable, Codable, Hashable {
    let id: String
    let kind: MediaAssetKind
    let title: String
    let caption: String
    let localResourceName: String?
}

struct POI: Identifiable, Codable, Hashable {
    let id: String
    let routeID: String
    let title: String
    let summary: String
    let detailedText: String
    let cueText: String
    let sideHint: String
    let triggerRadiusMeters: Double
    let coordinate: CoordinatePoint
    let mediaAssets: [MediaAsset]
    let estimatedMinutesFromStart: Int

    var photoAsset: MediaAsset? {
        mediaAssets.first(where: { $0.kind == .photo })
    }

    var audioAsset: MediaAsset? {
        mediaAssets.first(where: { $0.kind == .audio })
    }
}

struct Route: Identifiable, Codable, Hashable {
    let id: String
    let airportID: String
    let packageID: String
    let title: String
    let summary: String
    let durationMinutes: Int
    let distanceKilometers: Double
    let downloadSizeMB: Int
    let contentLanguages: [ContentLanguage]
    let previewSymbol: String
    let polyline: [CoordinatePoint]
    let poi: [POI]
}

