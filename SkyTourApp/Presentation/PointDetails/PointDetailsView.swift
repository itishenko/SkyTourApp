import SwiftUI

struct PointDetailsView: View {
    @EnvironmentObject private var appState: AppState

    let poi: POI?

    var body: some View {
        SkyTourScaffold(title: "Карточка точки", subtitle: poi?.title ?? "POI") {
            if let poi {
                PlaceholderIllustrationCard(
                    title: poi.title,
                    subtitle: poi.sideHint,
                    symbol: poi.audioAsset == nil ? "photo.fill" : "waveform"
                )

                SkyTourCard {
                    Text(poi.summary)
                        .font(.headline)
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(poi.detailedText)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }

                SkyTourCard {
                    InlineInfoRow(title: "Подсказка", value: poi.cueText)
                    InlineInfoRow(title: "Радиус", value: "\(Int(poi.triggerRadiusMeters)) м")
                    InlineInfoRow(title: "От старта", value: "\(poi.estimatedMinutesFromStart) мин")
                }

                HStack(spacing: 12) {
                    Button("Воспроизвести аудио") {
                        Task { await appState.playPOI(poi) }
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Button("Пауза") {
                        Task { await appState.pauseAudio() }
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }
            } else {
                EmptyStateCard(title: "POI не найден", message: "Откройте карточку точки из режима полета.")
            }
        }
        .navigationTitle("Точка")
        .navigationBarTitleDisplayMode(.inline)
    }
}

