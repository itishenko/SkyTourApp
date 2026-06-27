import Foundation

@MainActor
struct PlaceholderMapService: MapService {
    func renderSnapshot(route: Route?, activePOI: POI?, gpsStatus: GPSStatus) -> MapRenderSnapshot {
        MapRenderSnapshot(
            title: route?.title ?? "Свободный полет",
            subtitle: activePOI?.title ?? "Mapbox подключается через абстракцию на следующем этапе.",
            visiblePOICount: route?.poi.count ?? 0,
            mapStatus: gpsStatus == .active ? .unavailableInSDK : .missing
        )
    }
}
