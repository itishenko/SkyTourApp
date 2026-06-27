import SwiftUI

struct LocationPermissionView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SkyTourScaffold(title: "Геолокация", subtitle: "Нужна для определения аэропорта и сопровождения маршрута") {
            SkyTourCard(accentGlow: true) {
                InlineInfoRow(title: "Статус", value: appState.locationPermissionState.rawValue)
                InlineInfoRow(title: "GPS", value: appState.gpsStatus.title)
                Text("В MVP доступ к геолокации используется только для поиска ближайшего поддерживаемого аэропорта и контекстного сопровождения полета.")
                    .font(.subheadline)
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }

            if appState.locationPermissionState == .denied || appState.locationPermissionState == .restricted {
                SkyTourCard {
                    Text("Доступ не выдан")
                        .font(.headline)
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text("Можно открыть настройки iOS или продолжить с ручным выбором аэропорта. Полетный режим будет работать ограниченно без GPS.")
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }
            }

            Button("Разрешить доступ") {
                Task { await appState.requestLocationAccess() }
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button("Сейчас не давать доступ") {
                Task { await appState.denyLocationAccess() }
            }
            .buttonStyle(SecondaryActionButtonStyle())

            if appState.locationPermissionState == .denied || appState.locationPermissionState == .restricted {
                Button("Выбрать аэропорт вручную") {
                    appState.requestManualAirportSelection()
                }
                .buttonStyle(SecondaryActionButtonStyle())

                Button("Открыть Settings") {
                    appState.openSystemSettings()
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
        }
    }
}

