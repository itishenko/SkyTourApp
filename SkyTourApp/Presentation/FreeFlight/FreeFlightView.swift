import SwiftUI

struct FreeFlightView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    private var availablePOI: [POI] {
        appState.availablePOIForFreeFlight()
    }

    var body: some View {
        SkyTourScaffold(title: "Свободный полет", subtitle: "Точки рядом") {
            if availablePOI.isEmpty {
                EmptyStateCard(
                    title: "Нет скачанных точек",
                    message: "Сначала скачайте хотя бы один route pack для выбранного аэропорта."
                )
            } else {
                SkyTourCard(accentGlow: true) {
                    Text("Доступно \(availablePOI.count) POI для свободного полета.")
                        .font(.headline)
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text("Сценарий не зависит от выбранного маршрута и использует уже загруженные пакеты.")
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }

                ForEach(availablePOI) { point in
                    Button {
                        router.push(.pointDetails(point.id))
                    } label: {
                        SkyTourCard {
                            Text(point.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(SkyTourTheme.textPrimary)
                            Text(point.summary)
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                    }
                    .buttonStyle(.plain)
                }

                Button("Запустить free flight") {
                    router.push(.preflight(nil))
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
        .navigationTitle("Free Flight")
        .navigationBarTitleDisplayMode(.inline)
    }
}
