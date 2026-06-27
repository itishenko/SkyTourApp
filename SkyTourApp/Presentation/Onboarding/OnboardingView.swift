import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        SkyTourScaffold(title: "SkyTour", subtitle: "Интерактивный помощник для экскурсионных полетов") {
            PlaceholderIllustrationCard(
                title: "Только approved sightseeing routes",
                subtitle: "SkyTour помогает заранее загрузить маршрут, точки интереса, фото и аудио, чтобы сопровождать полет даже без интернета.",
                symbol: "airplane.departure"
            )

            SkyTourCard {
                Text("Важно")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SkyTourTheme.textPrimary)
                Text("Приложение не является авиационным навигатором и не заменяет официальные карты, приборы, диспетчерские указания и решения пилота.")
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }

            Button("Начать") {
                appState.completeOnboarding()
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
    }
}

