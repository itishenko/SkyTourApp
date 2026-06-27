import SwiftUI

struct AirportSelectionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let allowsBackNavigation: Bool
    @State private var searchText = ""

    init(allowsBackNavigation: Bool = false) {
        self.allowsBackNavigation = allowsBackNavigation
    }

    private var filteredAirports: [Airport] {
        let base = appState.airports.filter {
            searchText.isEmpty
            || $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.code.localizedCaseInsensitiveContains(searchText)
            || $0.city.localizedCaseInsensitiveContains(searchText)
        }
        return base.sorted { $0.name < $1.name }
    }

    var body: some View {
        SkyTourScaffold(title: "Молдова · аэропорты", subtitle: "Выберите точку вылета") {
            if let nearest = appState.nearestAirportMatch {
                SkyTourCard(accentGlow: true) {
                    Text("Ближайший аэропорт")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text("\(nearest.airport.name) · \(nearest.airport.code)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(String(format: "%.1f км · %@", nearest.distanceKilometers, nearest.isSupported ? "поддерживается" : "не поддерживается"))
                        .foregroundStyle(SkyTourTheme.textSecondary)

                    HStack(spacing: 12) {
                        Button("Использовать этот аэропорт") {
                            appState.confirmNearestAirport()
                            dismissIfNeeded()
                        }
                        .buttonStyle(PrimaryActionButtonStyle())
                    }
                }
            }

            SkyTourCard {
                TextField("Поиск по аэропорту или ICAO", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundStyle(SkyTourTheme.textPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(SkyTourTheme.cardSecondary)
                    )
            }

            SkyTourSectionHeader(
                title: "Поддерживаемые аэропорты",
                subtitle: "MVP стартует с Chisinau / LUKK и mock-контентом по Молдове."
            )

            ForEach(filteredAirports) { airport in
                Button {
                    appState.selectAirport(airport)
                    dismissIfNeeded()
                } label: {
                    SkyTourCard {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(airport.name)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(SkyTourTheme.textPrimary)
                                Text("\(airport.city) · \(airport.code)")
                                    .foregroundStyle(SkyTourTheme.textSecondary)
                                HStack(spacing: 10) {
                                    StatusBadge(
                                        title: airport.isSupported ? "поддерживается" : "не поддерживается",
                                        tint: airport.isSupported ? SkyTourTheme.accent : SkyTourTheme.warning
                                    )
                                    Text("\(airport.routeIDs.count) маршрутов")
                                        .font(.caption)
                                        .foregroundStyle(SkyTourTheme.textSecondary)
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(SkyTourTheme.textSecondary)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(allowsBackNavigation ? "Аэропорт" : "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(allowsBackNavigation ? .visible : .hidden, for: .navigationBar)
    }

    private func dismissIfNeeded() {
        guard allowsBackNavigation else { return }
        dismiss()
    }
}

