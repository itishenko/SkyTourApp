import Foundation
import MapboxMaps

@MainActor
struct MapboxMapService: MapService {
    private let accessToken: String?

    init(accessToken: String? = Bundle.main.object(forInfoDictionaryKey: "MBXAccessToken") as? String) {
        let normalizedToken = accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let normalizedToken, !normalizedToken.isEmpty {
            self.accessToken = normalizedToken
            MapboxOptions.accessToken = normalizedToken
        } else {
            self.accessToken = nil
        }
    }

    func renderSnapshot(
        route: Route?,
        availablePOI: [POI],
        activePOI: POI?,
        currentLocation: CoordinatePoint?,
        gpsStatus: GPSStatus
    ) -> MapRenderSnapshot {
        let sourcePOI = route?.poi ?? availablePOI

        let pointsOfInterest = sourcePOI.map { poi in
            MapPOISnapshot(
                id: poi.id,
                title: poi.title,
                coordinate: poi.coordinate,
                isActive: poi.id == activePOI?.id
            )
        }

        let isConfigured = accessToken != nil
        let warningMessage = warningMessage(
            isConfigured: isConfigured,
            currentLocation: currentLocation,
            gpsStatus: gpsStatus
        )

        return MapRenderSnapshot(
            title: route?.title ?? "Свободный полет",
            subtitle: activePOI?.title ?? route?.summary ?? "Живая карта маршрута и POI.",
            visiblePOICount: pointsOfInterest.count,
            mapStatus: isConfigured ? .available : .missing,
            isMapConfigured: isConfigured,
            routeCoordinates: route?.polyline ?? [],
            pointsOfInterest: pointsOfInterest,
            currentLocation: currentLocation,
            focusCoordinate: currentLocation ?? activePOI?.coordinate ?? route?.polyline.first ?? pointsOfInterest.first?.coordinate,
            warningMessage: warningMessage
        )
    }

    private func warningMessage(
        isConfigured: Bool,
        currentLocation: CoordinatePoint?,
        gpsStatus: GPSStatus
    ) -> String? {
        if !isConfigured {
            return "Добавьте публичный токен Mapbox в build setting MAPBOX_ACCESS_TOKEN, чтобы включить живую карту."
        }

        if gpsStatus == .unavailable {
            return "Карта загружена, но текущая позиция недоступна без доступа к геолокации."
        }

        if gpsStatus == .limited || currentLocation == nil {
            return "Mapbox готов. Ожидаем первый GPS-фикс, чтобы показать текущую позицию."
        }

        return nil
    }
}
