import SwiftUI

enum SkyTourTheme {
    static let backgroundTop = Color(red: 0.03, green: 0.07, blue: 0.06)
    static let backgroundBottom = Color(red: 0.01, green: 0.03, blue: 0.03)
    static let card = Color(red: 0.08, green: 0.11, blue: 0.11)
    static let cardSecondary = Color(red: 0.11, green: 0.14, blue: 0.14)
    static let accent = Color(red: 0.66, green: 0.98, blue: 0.46)
    static let accentMuted = Color(red: 0.36, green: 0.52, blue: 0.23)
    static let outline = Color.white.opacity(0.08)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let warning = Color(red: 0.99, green: 0.76, blue: 0.31)
    static let error = Color(red: 0.99, green: 0.45, blue: 0.39)
}

struct SkyTourScaffold<Content: View>: View {
    let title: String?
    let subtitle: String?
    @ViewBuilder let content: Content

    init(
        title: String? = nil,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SkyTourTheme.backgroundTop, SkyTourTheme.backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let title {
                        ScreenTitleBlock(title: title, subtitle: subtitle)
                    }

                    content
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
    }
}

struct ScreenTitleBlock: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption)
                .tracking(3)
                .foregroundStyle(SkyTourTheme.textSecondary)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(SkyTourTheme.textPrimary)
            }
        }
    }
}

struct SkyTourCard<Content: View>: View {
    let accentGlow: Bool
    @ViewBuilder let content: Content

    init(accentGlow: Bool = false, @ViewBuilder content: () -> Content) {
        self.accentGlow = accentGlow
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(SkyTourTheme.card)
                if accentGlow {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [SkyTourTheme.accent.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(SkyTourTheme.outline, lineWidth: 1)
        )
    }
}

struct StatusBadge: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title.uppercased())
            .font(.caption2.weight(.semibold))
            .tracking(1.2)
            .foregroundStyle(.black.opacity(0.85))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(tint)
            )
    }
}

struct MetricPill: View {
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(SkyTourTheme.textPrimary)
            Text(title.uppercased())
                .font(.caption2)
                .tracking(1.4)
                .foregroundStyle(SkyTourTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(SkyTourTheme.cardSecondary)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(SkyTourTheme.outline, lineWidth: 1)
        )
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.black.opacity(0.86))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(SkyTourTheme.accent)
                    .opacity(configuration.isPressed ? 0.82 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(SkyTourTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(SkyTourTheme.cardSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(SkyTourTheme.outline, lineWidth: 1)
                    )
                    .opacity(configuration.isPressed ? 0.82 : 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SkyTourSectionHeader: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(SkyTourTheme.textPrimary)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SkyTourTheme.textSecondary)
            }
        }
    }
}

struct InlineInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(SkyTourTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(SkyTourTheme.textPrimary)
        }
        .font(.subheadline)
    }
}

struct RoutePolylinePreview: View {
    let route: Route

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [SkyTourTheme.accent.opacity(0.4), SkyTourTheme.cardSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Canvas { context, size in
                    guard route.polyline.count > 1 else { return }

                    let xs = route.polyline.map(\.longitude)
                    let ys = route.polyline.map(\.latitude)
                    guard let minX = xs.min(),
                          let maxX = xs.max(),
                          let minY = ys.min(),
                          let maxY = ys.max() else { return }

                    func point(_ coordinate: CoordinatePoint) -> CGPoint {
                        let xSpan = max(maxX - minX, 0.001)
                        let ySpan = max(maxY - minY, 0.001)
                        let x = ((coordinate.longitude - minX) / xSpan) * (size.width - 36) + 18
                        let y = ((coordinate.latitude - minY) / ySpan) * (size.height - 36) + 18
                        return CGPoint(x: x, y: size.height - y)
                    }

                    var path = Path()
                    path.addLines(route.polyline.map(point))
                    context.stroke(path, with: .color(.white.opacity(0.75)), lineWidth: 3)

                    for poi in route.poi {
                        let circle = Path(ellipseIn: CGRect(origin: point(poi.coordinate), size: .zero).insetBy(dx: -4, dy: -4))
                        context.fill(circle, with: .color(SkyTourTheme.accent))
                    }
                }

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: route.previewSymbol)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.black.opacity(0.75))
                            .padding(10)
                            .background(Circle().fill(SkyTourTheme.accent))
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }
                .padding(14)
            }
        }
        .frame(height: 156)
    }
}

struct PlaceholderIllustrationCard: View {
    let title: String
    let subtitle: String
    let symbol: String

    var body: some View {
        SkyTourCard(accentGlow: true) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(SkyTourTheme.textPrimary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(SkyTourTheme.textSecondary)
                }
                Spacer()
                Image(systemName: symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.black.opacity(0.8))
                    .padding(16)
                    .background(Circle().fill(SkyTourTheme.accent))
            }
        }
    }
}

struct EmptyStateCard: View {
    let title: String
    let message: String

    var body: some View {
        SkyTourCard {
            Text(title)
                .font(.headline)
                .foregroundStyle(SkyTourTheme.textPrimary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(SkyTourTheme.textSecondary)
        }
    }
}

