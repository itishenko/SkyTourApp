import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SkyTourScaffold(title: "Настройки", subtitle: "Язык, аудио, GPS") {
            SkyTourCard {
                Text("Контент")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)

                Picker(
                    "Язык",
                    selection: Binding(
                        get: { appState.contentLanguage },
                        set: { appState.updateContentLanguage($0) }
                    )
                ) {
                    ForEach(ContentLanguage.allCases) { language in
                        Text(language.label).tag(language)
                    }
                }
                .pickerStyle(.segmented)

                Toggle(
                    "Автовоспроизведение аудио",
                    isOn: Binding(
                        get: { appState.autoplayAudio },
                        set: { appState.updateAutoplayAudio($0) }
                    )
                )
                .tint(SkyTourTheme.accent)
            }

            SkyTourCard {
                Text("Статус")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)
                InlineInfoRow(title: "GPS", value: appState.gpsStatus.title)
                InlineInfoRow(title: "Разрешение", value: appState.locationPermissionState.rawValue)
                InlineInfoRow(title: "Выбранный аэропорт", value: appState.selectedAirport?.code ?? "—")
            }

            SkyTourCard {
                Text("О приложении")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)
                Text("SkyTour — только информационный и экскурсионный помощник. Не для авиационной навигации.")
                    .foregroundStyle(SkyTourTheme.textSecondary)
                InlineInfoRow(title: "Версия", value: appState.appVersionDescription())
            }
        }
    }
}

