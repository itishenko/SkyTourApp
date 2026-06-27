import SwiftUI

struct FlightMapView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    let route: Route?

    private var snapshot: MapRenderSnapshot {
        appState.mapSnapshot(for: route)
    }

    var body: some View {
        SkyTourScaffold(title: "Режим полета", subtitle: route?.title ?? "Свободный полет") {
            SkyTourCard(accentGlow: true) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(snapshot.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(snapshot.subtitle)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    HStack(spacing: 12) {
                        MetricPill(value: "\(snapshot.visiblePOICount)", title: "poi")
                        MetricPill(value: appState.gpsStatus.title, title: "gps")
                        MetricPill(value: snapshot.mapStatus.title, title: "map")
                    }
                    if let route {
                        RoutePolylinePreview(route: route)
                    } else {
                        PlaceholderIllustrationCard(
                            title: "Mapbox container",
                            subtitle: "Сейчас это placeholder abstraction. Реальный SDK подключается следующим этапом через MapService.",
                            symbol: "map.fill"
                        )
                    }
                }
            }

            if let poi = appState.activePOI {
                SkyTourCard {
                    Text("Следующая точка")
                        .font(.caption)
                        .tracking(2)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    Text(poi.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(poi.summary)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    Text(poi.cueText)
                        .font(.headline)
                        .foregroundStyle(SkyTourTheme.accent)

                    HStack(spacing: 12) {
                        Button("Открыть карточку") {
                            router.push(.pointDetails(poi.id))
                        }
                        .buttonStyle(PrimaryActionButtonStyle())

                        Button("Пауза аудио") {
                            Task { await appState.pauseAudio() }
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                    }
                }
            }

            Button("Завершить сессию") {
                Task {
                    await appState.stopFlight()
                    dismiss()
                }
            }
            .buttonStyle(SecondaryActionButtonStyle())
        }
        .navigationTitle("Flight")
        .navigationBarTitleDisplayMode(.inline)
    }
}
