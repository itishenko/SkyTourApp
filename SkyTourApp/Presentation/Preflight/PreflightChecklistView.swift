import SwiftUI

struct PreflightChecklistView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var router: AppRouter
    @Environment(\.dismiss) private var dismiss

    let route: Route?
    @State private var checks: [PreflightCheckItem] = []

    private static let placeholderChecks: [PreflightCheckItem] = [
        PreflightCheckItem(id: "routeDownloaded", title: "Маршрут скачан", message: "", state: .warning),
        PreflightCheckItem(id: "pointsDownloaded", title: "Точки интереса скачаны", message: "", state: .warning),
        PreflightCheckItem(id: "audioAvailable", title: "Аудио доступно", message: "", state: .warning),
        PreflightCheckItem(id: "gpsActive", title: "GPS активен", message: "", state: .ready),
        PreflightCheckItem(id: "offlineModeReady", title: "Офлайн-режим готов", message: "", state: .ready)
    ]

    var body: some View {
        ZStack {
            background

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    checklistCard
                    warningCard
                    primaryButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 56)
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: route?.id) {
            checks = await appState.makePreflightChecklist(for: route)
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.02, green: 0.06, blue: 0.06),
                    Color(red: 0.01, green: 0.04, blue: 0.04)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [
                    Color(red: 0.22, green: 0.44, blue: 0.20).opacity(0.24),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: { dismiss() }) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.045))
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.86))
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 8) {
                Text("ПРЕДПОЛЁТНАЯ ПРОВЕРКА")
                    .font(.system(size: 13, weight: .medium))
                    .tracking(3.6)
                    .foregroundStyle(Color.white.opacity(0.62))

                Text("Готов к старту")
                    .font(.system(size: 31, weight: .bold, design: .serif))
                    .foregroundStyle(.white.opacity(0.96))
                    .lineLimit(1)
                    .minimumScaleFactor(0.92)
            }
        }
    }

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(visibleChecks) { item in
                ChecklistRow(item: item)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.09, green: 0.12, blue: 0.12).opacity(0.96),
                            Color(red: 0.04, green: 0.08, blue: 0.08).opacity(0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 42, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.24, green: 0.47, blue: 0.18).opacity(0.22),
                                    .clear
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.22), radius: 22, y: 12)
    }

    private var warningCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ПРЕДУПРЕЖДЕНИЕ")
                .font(.system(size: 13, weight: .medium))
                .tracking(3.2)
                .foregroundStyle(Color.white.opacity(0.74))

            Text("Только экскурсионный помощник. Приложение не заменяет авиационную навигацию, AIP, NOTAM, ATC и ответственность пилота.")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.58))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.white.opacity(0.045))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1.2)
        )
    }

    private var primaryButton: some View {
        Button(action: primaryAction) {
            Text(primaryActionTitle)
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 26)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(red: 0.49, green: 0.99, blue: 0.40))
                )
        }
        .buttonStyle(.plain)
    }

    private var visibleChecks: [PreflightCheckItem] {
        checks.isEmpty ? Self.placeholderChecks : checks
    }

    private var primaryActionTitle: String {
        if route == nil {
            return isChecklistReady ? "Начать свободный полёт" : "Нужен активный GPS"
        }

        if !isRouteDownloaded {
            return "Маршрут не готов офлайн"
        }

        return isChecklistReady ? "Начать маршрут" : "Нужно завершить проверку"
    }

    private var isChecklistReady: Bool {
        checkState(for: "routeDownloaded") == .ready &&
        checkState(for: "pointsDownloaded") == .ready &&
        checkState(for: "audioAvailable") == .ready &&
        checkState(for: "gpsActive") == .ready &&
        checkState(for: "offlineModeReady") == .ready
    }

    private var isRouteDownloaded: Bool {
        checkState(for: "routeDownloaded") == .ready
    }

    private func checkState(for id: String) -> PreflightCheckState? {
        visibleChecks.first(where: { $0.id == id })?.state
    }

    private func primaryAction() {
        if isChecklistReady {
            Task {
                let mode: FlightModeKind = route == nil ? .freeFlight : .guided
                let session = await appState.startFlight(route: route, mode: mode)
                guard session != nil else { return }
                router.push(.flight(route?.id))
            }
            return
        }

        if let packageID = route?.packageID ?? appState.selectedPackage?.id {
            router.push(.packageDetails(packageID))
            return
        }

        openRoutes()
    }

    private func openRoutes() {
        router.selectedTab = .home
        router.popToRoot()
        router.push(.routes)
    }
}

private struct ChecklistRow: View {
    let item: PreflightCheckItem

    private var isReady: Bool {
        item.state == .ready
    }

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isReady ? Color(red: 0.49, green: 0.99, blue: 0.40) : Color.white.opacity(0.14))
                    .frame(width: 30, height: 30)
                    .shadow(color: isReady ? Color(red: 0.49, green: 0.99, blue: 0.40).opacity(0.30) : .clear, radius: 12, y: 5)

                Image(systemName: isReady ? "checkmark" : "exclamationmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(isReady ? Color.black.opacity(0.9) : Color.white.opacity(0.85))
            }

            Text(item.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isReady ? Color.white.opacity(0.92) : Color.white.opacity(0.56))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
