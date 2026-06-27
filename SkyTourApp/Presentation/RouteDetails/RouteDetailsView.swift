import SwiftUI

struct RouteDetailsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    let route: Route?

    var body: some View {
        SkyTourScaffold(title: "Route Details", subtitle: route?.title ?? "Маршрут") {
            if let route {
                RoutePolylinePreview(route: route)

                SkyTourCard {
                    Text(route.summary)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    HStack {
                        MetricPill(value: "\(route.durationMinutes)", title: "мин")
                        MetricPill(value: String(format: "%.0f", route.distanceKilometers), title: "км")
                        MetricPill(value: "\(route.poi.count)", title: "poi")
                    }
                }

                SkyTourCard {
                    Text("Точки маршрута")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    ForEach(route.poi) { poi in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(poi.title)
                                .foregroundStyle(SkyTourTheme.textPrimary)
                            Text(poi.summary)
                                .font(.subheadline)
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button("Скачать маршрут") {
                        router.push(.packageDetails(route.packageID))
                    }
                    .buttonStyle(SecondaryActionButtonStyle())

                    Button("Предполетная проверка") {
                        appState.selectRoute(route)
                        router.push(.preflight(route.id))
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }

                SkyTourCard {
                    Text("Только экскурсионный помощник · Не для навигации")
                        .font(.caption)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }
            } else {
                EmptyStateCard(title: "Маршрут не найден", message: "Проверьте выбранный airport context.")
            }
        }
        .navigationTitle("Маршрут")
        .navigationBarTitleDisplayMode(.inline)
    }
}

