import Foundation

struct FlightSession: Identifiable, Codable, Hashable {
    let id: UUID
    let airportID: String
    let routeID: String?
    let packageID: String?
    let mode: FlightModeKind
    let startedAt: Date
    let currentPOIID: String?
    let nextPOIID: String?
    let completedPOIIDs: [String]
    let isDeviationDetected: Bool
}

