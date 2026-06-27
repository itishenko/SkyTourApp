import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        SkyTourScaffold(
            title: "Молдова · текущий аэропорт",
            subtitle: appState.selectedAirport?.name ?? "Аэропорт не выбран"
        ) {
            airportCard
            readyCard
            routesSection
            packagesSection
            freeFlightSection
            footerCard
        }
        .navigationBarHidden(true)
    }

    private var airportCard: some View {
        SkyTourCard {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Текущий аэропорт")
                        .font(.caption)
                        .tracking(2)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    Text("\(appState.selectedAirport?.name ?? "—") · \(appState.selectedAirport?.code ?? "—")")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text("GPS \(appState.gpsStatus.title) · \(appState.selectedCountry?.name ?? "Moldova")")
                        .font(.subheadline)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }
                Spacer()
                Button("Сменить") {
                    router.push(.airports)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(SkyTourTheme.accent)
            }

            HStack(spacing: 10) {
                MetricPill(value: "\(appState.routes(for: appState.selectedAirport).count)", title: "маршруты")
                MetricPill(value: "\(appState.packages(for: appState.selectedAirport).count)", title: "пакеты")
                MetricPill(value: "\(appState.downloadedRoutesCount(for: appState.selectedAirport))", title: "офлайн")
            }
        }
    }

    private var readyCard: some View {
        SkyTourCard(accentGlow: true) {
            Text("Готово к офлайн-полету")
                .font(.caption)
                .tracking(3)
                .foregroundStyle(SkyTourTheme.accent)
            Text("\(appState.downloadedRoutesCount(for: appState.selectedAirport)) маршрутов скачано")
                .font(.title3.weight(.semibold))
                .foregroundStyle(SkyTourTheme.textPrimary)
            Text("Подготовка для \(appState.selectedAirport?.name ?? "аэропорта"). Перед вылетом проверьте пакет, GPS и legal disclaimer.")
                .foregroundStyle(SkyTourTheme.textSecondary)

            HStack(spacing: 12) {
                Button("Начать предполетную проверку") {
                    router.push(.preflight(appState.selectedRoute?.id))
                }
                .buttonStyle(PrimaryActionButtonStyle())

                Button("Выбрать маршрут") {
                    router.push(.routes)
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }

    private var routesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkyTourSectionHeader(title: "Готово офлайн · \(appState.selectedAirport?.code ?? "LUKK")", subtitle: nil)

            ForEach(appState.routes(for: appState.selectedAirport)) { route in
                Button {
                    appState.selectRoute(route)
                    router.push(.routeDetails(route.id))
                } label: {
                    SkyTourCard(accentGlow: appState.installedPackageIDs.contains(route.packageID)) {
                        HStack(alignment: .top, spacing: 14) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [SkyTourTheme.accent.opacity(0.7), SkyTourTheme.cardSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 54, height: 54)
                                .overlay(
                                    Image(systemName: route.previewSymbol)
                                        .foregroundStyle(.black.opacity(0.75))
                                )

                            VStack(alignment: .leading, spacing: 8) {
                                Text(route.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SkyTourTheme.textPrimary)
                                Text("\(route.durationMinutes) мин · \(route.poi.count) POI · \(route.downloadSizeMB) МБ")
                                    .foregroundStyle(SkyTourTheme.textSecondary)
                                HStack(spacing: 6) {
                                    StatusBadge(
                                        title: appState.packageState(for: appState.routePackage(id: route.packageID) ?? appState.selectedPackage ?? fallbackPackage).title,
                                        tint: statusTint(for: route)
                                    )
                                    ForEach(route.contentLanguages) { language in
                                        Text(language.label)
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(SkyTourTheme.textSecondary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Capsule().fill(SkyTourTheme.cardSecondary))
                                    }
                                }
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var packagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SkyTourSectionHeader(title: "Route packs", subtitle: "Наборы для работы без интернета")
            ForEach(appState.packages(for: appState.selectedAirport)) { package in
                Button {
                    appState.selectPackage(package)
                    router.push(.packageDetails(package.id))
                } label: {
                    SkyTourCard {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Route Pack")
                                    .font(.caption)
                                    .foregroundStyle(SkyTourTheme.textSecondary)
                                Text(package.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SkyTourTheme.textPrimary)
                                Text("\(package.routeIDs.count) routes · \(package.poiCount) POI · \(package.sizeMB) МБ")
                                    .foregroundStyle(SkyTourTheme.textSecondary)
                            }
                            Spacer()
                            StatusBadge(title: appState.packageState(for: package).title, tint: statusTint(for: package))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var freeFlightSection: some View {
        Button {
            router.push(.freeFlight)
        } label: {
            SkyTourCard {
                Text("Свободный полет")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)
                Text("Показывает ближайшие скачанные точки без выбранного маршрута. Работает только с уже скачанными зонами.")
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var footerCard: some View {
        SkyTourCard {
            Text("Только экскурсионный помощник · Не для навигации")
                .font(.caption)
                .foregroundStyle(SkyTourTheme.textSecondary)
        }
    }

    private var fallbackPackage: RoutePackage {
        appState.routePackages.first!
    }

    private func statusTint(for route: Route) -> Color {
        appState.installedPackageIDs.contains(route.packageID) ? SkyTourTheme.accent : SkyTourTheme.warning
    }

    private func statusTint(for package: RoutePackage) -> Color {
        appState.installedPackageIDs.contains(package.id) ? SkyTourTheme.accent : SkyTourTheme.warning
    }
}

