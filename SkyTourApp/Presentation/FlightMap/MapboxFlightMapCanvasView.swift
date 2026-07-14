import CoreLocation
import SwiftUI
import Turf
import UIKit
@_spi(Experimental) import MapboxMaps

struct MapboxFlightMapCanvasView: View {
    private enum Constants {
        static let defaultCenter = CLLocationCoordinate2D(latitude: 47.0105, longitude: 28.8638) // FIXME
        static let routeLayerID = "flight-route-layer"
        static let routeFeatureID = "flight-route-feature"
    }

    let snapshot: MapRenderSnapshot

    @State private var viewport: Viewport = .camera(center: Constants.defaultCenter, zoom: 7, bearing: 0, pitch: 0)

    var body: some View {
        Map(viewport: $viewport) {
            if routeCoordinates.count > 1 {
                PolylineAnnotationGroup {
                    PolylineAnnotation(
                        id: Constants.routeFeatureID,
                        lineCoordinates: routeCoordinates
                    )
                    .lineColor("#FF7B1C")
                    .lineBorderColor("#FFF8F1")
                    .lineWidth(7)
                    .lineBorderWidth(2)
                }
                .lineDashArray([1.35, 1.05])
                .lineOpacity(0.98)
                .layerId(Constants.routeLayerID)
                .lineCap(.round)
                .slot(.middle)
            }

            ForEvery(snapshot.pointsOfInterest) { point in
                MapViewAnnotation(coordinate: point.coordinate.clLocationCoordinate2D) {
                    POIBadge(point: point)
                }
                .allowOverlap(true)
            }

            if let aircraftCoordinate {
                MapViewAnnotation(coordinate: aircraftCoordinate) {
                    AircraftMarker()
                }
                .allowOverlap(true)
            }
        }
        .mapStyle(.standard(lightPreset: .day))
        .onAppear(perform: updateViewport)
        .onChange(of: snapshot) { _, _ in
            updateViewport()
        }
    }

    private var routeLine: LineString? {
        guard routeCoordinates.count > 1 else { return nil }
        return LineString(routeCoordinates)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        snapshot.routeCoordinates.map(\.clLocationCoordinate2D)
    }

    private var aircraftCoordinate: CLLocationCoordinate2D? {
        snapshot.currentLocation?.clLocationCoordinate2D
            ?? snapshot.routeCoordinates.first?.clLocationCoordinate2D
            ?? snapshot.focusCoordinate?.clLocationCoordinate2D
    }

    private func updateViewport() {
        if let routeLine {
            viewport = .overview(geometry: routeLine)
            return
        }

        if snapshot.currentLocation != nil {
            viewport = .followPuck(zoom: 11, bearing: .heading, pitch: 50)
            return
        }

        if let focusCoordinate = snapshot.focusCoordinate?.clLocationCoordinate2D {
            viewport = .camera(center: focusCoordinate, zoom: 11, bearing: 0, pitch: 0)
            return
        }

        viewport = .camera(center: Constants.defaultCenter, zoom: 7, bearing: 0, pitch: 0)
    }
}

private struct POIBadge: View {
    let point: MapPOISnapshot

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.white)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .fill(point.isActive ? Color(red: 1.0, green: 0.49, blue: 0.12) : Color(red: 0.05, green: 0.10, blue: 0.18))
                        .frame(width: point.isActive ? 24 : 22, height: point.isActive ? 24 : 22)
                        .overlay {
                            if point.isActive {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                )

            Text(point.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black.opacity(0.78))
                .lineLimit(1)
        }
        .padding(.leading, 6)
        .padding(.trailing, 14)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.96))
        )
        .shadow(color: .black.opacity(0.22), radius: 12, y: 8)
    }
}

private struct AircraftMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 1.0, green: 0.62, blue: 0.43).opacity(0.28))
                .frame(width: 70, height: 70)

            Circle()
                .fill(Color(red: 1.0, green: 0.62, blue: 0.43).opacity(0.18))
                .frame(width: 46, height: 46)

            Image(systemName: "airplane")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(.black.opacity(0.86))
                .rotationEffect(.degrees(-20))
        }
    }
}

private extension CoordinatePoint {
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
