import Foundation

struct Airport: Identifiable, Codable, Hashable {
    let id: String
    let countryCode: String
    let code: String
    let name: String
    let city: String
    let latitude: Double
    let longitude: Double
    let isSupported: Bool
    let routeIDs: [String]
    let routePackageIDs: [String]
}

