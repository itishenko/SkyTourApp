import CoreLocation
import SwiftUI
import Turf
import UIKit
@_spi(Experimental) import MapboxMaps

struct MapboxFlightMapCanvasView: View {
    private enum Constants {
        static let defaultCenter = CLLocationCoordinate2D(latitude: 47.0105, longitude: 28.8638)
        static let routeLayerID = "flight-route-layer"
        static let routeFeatureID = "flight-route-feature"
    }

    let snapshot: MapRenderSnapshot

    @Environment(\.colorScheme) private var colorScheme
    @State private var viewport: Viewport = .camera(center: Constants.defaultCenter, zoom: 7, bearing: 0, pitch: 0)

    var body: some View {
        Map(viewport: $viewport) {
            if routeCoordinates.count > 1 {
                PolylineAnnotationGroup {
                    PolylineAnnotation(
                        id: Constants.routeFeatureID,
                        lineCoordinates: routeCoordinates
                    )
                    .lineColor("#40DCCE")
                    .lineBorderColor("#177B71")
                    .lineWidth(7)
                    .lineBorderWidth(2)
                }
                .layerId(Constants.routeLayerID)
                .lineCap(.round)
                .slot(.middle)
            }

            ForEvery(snapshot.pointsOfInterest) { point in
                MapViewAnnotation(coordinate: point.coordinate.clLocationCoordinate2D) {
                    POIAnnotationBadge(point: point)
                }
                .allowOverlap(true)
            }

            if snapshot.currentLocation != nil {
                Puck2D(bearing: .heading)
                    .showsAccuracyRing(true)
            }
        }
        .mapStyle(.standard(lightPreset: colorScheme == .dark ? .dusk : .day))
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

private struct POIAnnotationBadge: View {
    let point: MapPOISnapshot

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(point.isActive ? SkyTourTheme.accent : SkyTourTheme.warning)
                .frame(width: point.isActive ? 18 : 14, height: point.isActive ? 18 : 14)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.22), lineWidth: 1)
                )

            Text(point.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SkyTourTheme.textPrimary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(SkyTourTheme.card.opacity(0.92))
                )
        }
        .shadow(color: .black.opacity(0.22), radius: 12, y: 8)
    }
}

private extension CoordinatePoint {
    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
