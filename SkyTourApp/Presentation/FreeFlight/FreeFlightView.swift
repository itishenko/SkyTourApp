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
                    title: "Нет доступных точек",
                    message: "Для свободного полета пока нет POI в доступных маршрутах."
                )
            } else {
                SkyTourCard(accentGlow: true) {
                    Text("Доступно \(availablePOI.count) POI для свободного полета.")
                        .font(.headline)
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text("Свободный полет показывает точки сразу со всех маршрутов и подсказывает ближайшую внизу карты.")
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
