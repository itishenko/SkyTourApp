import SwiftUI

struct PackageListView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        SkyTourScaffold(title: "Route Packs", subtitle: appState.selectedAirport?.name ?? "Состав офлайн-наборов") {
            ForEach(appState.packages(for: appState.selectedAirport)) { package in
                Button {
                    appState.selectPackage(package)
                    router.push(.packageDetails(package.id))
                } label: {
                    SkyTourCard(accentGlow: appState.installedPackageIDs.contains(package.id)) {
                        Text(package.title)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(SkyTourTheme.textPrimary)
                        Text(package.summary)
                            .foregroundStyle(SkyTourTheme.textSecondary)
                        HStack {
                            Text("\(package.routeIDs.count) маршрутов")
                            Spacer()
                            Text("\(package.poiCount) POI")
                            Spacer()
                            Text("\(package.sizeMB) МБ")
                        }
                        .font(.subheadline)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Пакеты")
        .navigationBarTitleDisplayMode(.inline)
    }
}

