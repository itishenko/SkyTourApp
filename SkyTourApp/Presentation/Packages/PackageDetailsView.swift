import SwiftUI

struct PackageDetailsView: View {
    @EnvironmentObject private var appState: AppState

    let routePackage: RoutePackage?

    var body: some View {
        SkyTourScaffold(title: "Route Package", subtitle: routePackage?.title ?? "Офлайн-набор") {
            if let routePackage {
                SkyTourCard(accentGlow: true) {
                    Text(routePackage.summary)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                    InlineInfoRow(title: "Маршрутов", value: "\(routePackage.routeIDs.count)")
                    InlineInfoRow(title: "POI", value: "\(routePackage.poiCount)")
                    InlineInfoRow(title: "Размер", value: "\(routePackage.sizeMB) МБ")
                    InlineInfoRow(title: "Версия", value: routePackage.version)
                    InlineInfoRow(title: "Обновлено", value: routePackage.updatedAt.formatted(date: .abbreviated, time: .omitted))
                    InlineInfoRow(title: "Карта", value: routePackage.manifest.includesOfflineMap ? "ожидается" : "fallback")
                }

                SkyTourCard {
                    Text("Manifest")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    ForEach(routePackage.manifest.requiredFiles, id: \.self) { file in
                        Text("• \(file)")
                            .foregroundStyle(SkyTourTheme.textSecondary)
                    }
                }

                if let progress = appState.downloadProgress[routePackage.id] {
                    SkyTourCard {
                        Text("Скачивание")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(SkyTourTheme.textPrimary)
                        ProgressView(value: progress.fractionCompleted)
                            .tint(SkyTourTheme.accent)
                        Text("\(progress.currentStep) · \(Int(progress.fractionCompleted * 100))%")
                            .foregroundStyle(SkyTourTheme.textSecondary)
                        ForEach(progress.completedComponents, id: \.self) { component in
                            Text("• \(component)")
                                .font(.caption)
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                    }
                }

                HStack(spacing: 12) {
                    Button(primaryButtonTitle(for: routePackage)) {
                        Task {
                            if appState.installedPackageIDs.contains(routePackage.id) {
                                await appState.remove(routePackage)
                            } else {
                                await appState.download(routePackage)
                            }
                        }
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Button("Обновить") {
                        Task {
                            await appState.download(routePackage)
                        }
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            } else {
                EmptyStateCard(title: "Пакет не найден", message: "Выберите route pack с домашнего экрана.")
            }
        }
        .navigationTitle("Пакет")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func primaryButtonTitle(for package: RoutePackage) -> String {
        appState.installedPackageIDs.contains(package.id) ? "Удалить" : "Скачать"
    }
}

