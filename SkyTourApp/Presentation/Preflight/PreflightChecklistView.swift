import SwiftUI

struct PreflightChecklistView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter

    let route: Route?
    @State private var checks: [PreflightCheckItem] = []

    var body: some View {
        SkyTourScaffold(title: "Предполетная проверка", subtitle: route?.title ?? "Готовность к полету") {
            ForEach(checks) { item in
                SkyTourCard(accentGlow: item.state == .ready) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(SkyTourTheme.textPrimary)
                            Text(item.message)
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                        Spacer()
                        StatusBadge(title: item.state.title, tint: tint(for: item.state))
                    }
                }
            }

            Button(route == nil ? "Запустить свободный полет" : "Начать полет") {
                Task {
                    let session = await appState.startFlight(route: route, mode: route == nil ? .freeFlight : .guided)
                    guard session != nil else { return }
                    router.push(.flight(route?.id))
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .navigationTitle("Preflight")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: route?.id) {
            checks = await appState.makePreflightChecklist(for: route)
        }
    }

    private func tint(for state: PreflightCheckState) -> Color {
        switch state {
        case .ready: return SkyTourTheme.accent
        case .warning: return SkyTourTheme.warning
        case .failed: return SkyTourTheme.error
        }
    }
}

