import SwiftUI

struct RouteListView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        SkyTourScaffold(title: "Маршруты", subtitle: appState.selectedAirport?.name ?? "Каталог аэропорта") {
            SkyTourSectionHeader(
                title: "Доступные маршруты",
                subtitle: "MVP использует локальный Moldova content и route packs."
            )

            ForEach(appState.routes(for: appState.selectedAirport)) { route in
                SkyTourCard {
                    RoutePolylinePreview(route: route)
                    Text(route.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(route.summary)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    HStack {
                        Text("\(route.durationMinutes) мин")
                        Spacer()
                        Text(String(format: "%.0f км", route.distanceKilometers))
                        Spacer()
                        Text("\(route.poi.count) POI")
                    }
                    .font(.subheadline)
                    .foregroundStyle(SkyTourTheme.textSecondary)

                    HStack(spacing: 12) {
                        Button("Подробнее") {
                            appState.selectRoute(route)
                            router.push(.routeDetails(route.id))
                        }
                        .buttonStyle(PrimaryActionButtonStyle())

                        Button(appState.installedPackageIDs.contains(route.packageID) ? "Начать" : "Скачать") {
                            appState.selectRoute(route)
                            if appState.installedPackageIDs.contains(route.packageID) {
                                router.push(.preflight(route.id))
                            } else {
                                router.push(.packageDetails(route.packageID))
                            }
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                    }
                }
            }
        }
        .navigationTitle("Маршруты")
        .navigationBarTitleDisplayMode(.inline)
    }
}

