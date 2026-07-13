import CoreLocation
import SwiftUI

struct FlightMapView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    let route: Route?

    private var snapshot: MapRenderSnapshot {
        appState.mapSnapshot(for: route)
    }

    private var featuredPOI: POI? {
        appState.activePOI ?? route?.poi.first ?? appState.availablePOIForFreeFlight().first
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [SkyTourTheme.backgroundTop, SkyTourTheme.backgroundBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.03, green: 0.08, blue: 0.07),
                                    Color(red: 0.04, green: 0.08, blue: 0.07)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: geometry.safeAreaInsets.top + 118)

                    ZStack(alignment: .topLeading) {
                        if snapshot.isMapConfigured {
                            MapboxFlightMapCanvasView(snapshot: snapshot)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ZStack {
                                Color(red: 0.90, green: 0.90, blue: 0.88)
                                PlaceholderIllustrationCard(
                                    title: "Mapbox не настроен",
                                    subtitle: snapshot.warningMessage ?? "Добавьте публичный токен Mapbox, чтобы экран выглядел как в макете.",
                                    symbol: "map.fill"
                                )
                                .padding(24)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            FlightStatusPill(title: flightStatusTitle)
                                
                            Button(action: switchToFreeFlight) {
                                FlightActionPill(title: "Свободный полёт")
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 10)
                            

                            Button(action: changeRoute) {
                                FlightActionPill(title: "Сменить маршрут")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 16)
                        .padding(.leading, 16)

                        HStack {
                            Spacer()
                            Button(action: closeFlight) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.58))
                                    Circle()
                                        .stroke(Color.black.opacity(0.36), lineWidth: 2)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color.white.opacity(0.75))
                                }
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.2), radius: 14, y: 8)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 10)
                            .padding(.trailing, 22)
                        }
                    }
                }

                if let poi = featuredPOI {
                    HStack(spacing: 18) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.75, green: 0.69, blue: 0.44),
                                        Color(red: 0.57, green: 0.49, blue: 0.27)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 8) {
                            Text(poiContextLine(for: poi))
                                .font(.system(size: 15, weight: .bold, design: .default))
                                .tracking(0.8)
                                .foregroundStyle(Color(red: 0.49, green: 0.99, blue: 0.40))
                                .lineLimit(1)

                            Text(poi.title)
                                .font(.system(size: 16, weight: .semibold, design: .serif))
                                .foregroundStyle(SkyTourTheme.textPrimary)
                                .lineLimit(1)

                            Text(poiSecondaryLine(for: poi))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(SkyTourTheme.textSecondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 8)

                        Button {
                            router.push(.pointDetails(poi.id))
                        } label: {
                            Circle()
                                .fill(Color(red: 0.49, green: 0.99, blue: 0.40))
                                .frame(width: 38, height: 38)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.black.opacity(0.86))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 22)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.22, green: 0.23, blue: 0.22),
                                        Color(red: 0.20, green: 0.21, blue: 0.20),
                                        Color(red: 0.18, green: 0.23, blue: 0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 40, style: .continuous)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.28), radius: 24, y: 14)
                    .padding(.horizontal, 18)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 18))
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .preferredColorScheme(.dark)
    }

    private var flightStatusTitle: String {
        if let route {
            return "На маршруте · \(route.durationMinutes) мин"
        }
        return "Свободный полёт"
    }

    private func poiContextLine(for poi: POI) -> String {
        let direction = directionTitle(for: poi)
        if let distance = distanceKilometers(to: poi.coordinate) {
            return "ЧЕРЕЗ \(String(format: "%.1f", distance).replacingOccurrences(of: ".", with: ".")) КМ · \(direction) ▸"
        }
        return "МАРШРУТНАЯ ТОЧКА · \(direction) ▸"
    }

    private func poiSecondaryLine(for poi: POI) -> String {
        poi.photoAsset?.caption ?? poi.summary
    }

    private func directionTitle(for poi: POI) -> String {
        let hint = poi.sideHint.lowercased()
        if hint.contains("прав") {
            return "СПРАВА"
        }
        if hint.contains("лев") {
            return "СЛЕВА"
        }
        return "ПО КУРСУ"
    }

    private func distanceKilometers(to coordinate: CoordinatePoint) -> Double? {
        guard let currentLocation = appState.currentLocation else { return nil }
        let origin = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return origin.distance(from: target) / 1000
    }

    private func closeFlight() {
        Task {
            await appState.stopFlight()
            dismiss()
        }
    }

    private func switchToFreeFlight() {
        Task {
            await appState.stopFlight()
            router.popToRoot()
            router.push(.preflight(nil))
        }
    }

    private func changeRoute() {
        Task {
            await appState.stopFlight()
            router.popToRoot()
            router.push(.routes)
        }
    }
}

private struct FlightStatusPill: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(red: 0.49, green: 0.99, blue: 0.40))
                .frame(width: 15, height: 15)
                .shadow(color: Color(red: 0.49, green: 0.99, blue: 0.40).opacity(0.5), radius: 10)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(Color(red: 0.35, green: 0.37, blue: 0.35).opacity(0.96))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color.black.opacity(0.28), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.16), radius: 14, y: 8)
    }
}

private struct FlightActionPill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.white.opacity(0.68))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(red: 0.35, green: 0.37, blue: 0.35).opacity(0.96))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.black.opacity(0.28), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.12), radius: 10, y: 6)
    }
}
