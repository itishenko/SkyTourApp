import SwiftUI

struct OfflineManagerView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        SkyTourScaffold(title: "Офлайн", subtitle: "Готовность и пакеты") {
            SkyTourCard(accentGlow: true) {
                InlineInfoRow(title: "Скачано пакетов", value: "\(appState.installedPackageIDs.count)")
                InlineInfoRow(title: "Доступно маршрутов", value: "\(appState.downloadedRoutesCount(for: appState.selectedAirport))")
                InlineInfoRow(title: "Язык", value: appState.contentLanguage.label)
            }

            ForEach(appState.packages(for: appState.selectedAirport)) { package in
                SkyTourCard {
                    Text(package.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(package.summary)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    InlineInfoRow(title: "Статус", value: appState.packageState(for: package).title)
                    InlineInfoRow(title: "Версия", value: package.version)
                    InlineInfoRow(title: "Mapbox offline", value: package.manifest.includesOfflineMap ? "ожидается" : "fallback")

                    HStack(spacing: 12) {
                        Button("Открыть") {
                            router.selectedTab = .home
                            router.push(.packageDetails(package.id))
                        }
                        .buttonStyle(PrimaryActionButtonStyle())

                        Button(appState.installedPackageIDs.contains(package.id) ? "Удалить" : "Скачать") {
                            Task {
                                if appState.installedPackageIDs.contains(package.id) {
                                    await appState.remove(package)
                                } else {
                                    await appState.download(package)
                                }
                            }
                        }
                        .buttonStyle(SecondaryActionButtonStyle())
                    }
                }
            }
        }
    }
}

