import SwiftUI

struct LegalDisclaimerView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SkyTourScaffold(title: "Legal Disclaimer", subtitle: "Информационный и экскурсионный помощник") {
            SkyTourCard(accentGlow: true) {
                Text("SkyTour помогает сопровождать заранее разрешенный маршрут, но не предназначен для критически важных навигационных решений.")
                    .font(.headline)
                    .foregroundStyle(SkyTourTheme.textPrimary)
                Text("Не заменяет официальные авиационные карты, навигационные системы, приборы, указания диспетчеров и ответственность пилота.")
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }

            SkyTourCard {
                Text("Подтверждение")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)
                Text("Продолжая, пользователь подтверждает понимание не-навигационной роли приложения.")
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }

            Button("Принять и продолжить") {
                appState.acceptDisclaimer()
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }
}

