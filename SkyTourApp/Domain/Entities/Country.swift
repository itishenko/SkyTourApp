import Foundation

struct Country: Identifiable, Codable, Hashable {
    let id: String
    let code: String
    let name: String
    let airportIDs: [String]
}

