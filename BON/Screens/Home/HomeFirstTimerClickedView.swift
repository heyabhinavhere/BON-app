import SwiftUI

struct HomeFirstTimerClickedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scrollPosition = ScrollPosition(idType: Never.self)
    @State private var scrollOffset: CGFloat = 0
    @State private var didApplyInitialScrollTarget = false

    var aiEntryNamespace: Namespace.ID?
    var activeAIEntrySource: AIChatEntrySource = .cta
    var onOpenAI: (AIChatEntrySource) -> Void = { _ in }

    private let initialScrollTarget = HomeInitialScrollTarget.fromLaunchArguments()

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeFirstTimerLayoutMetrics(size: proxy.size)
            let isReduceMotionEnabled = reduceMotion
            let collapseProgress = metrics.chromeCollapseProgress(
                scrollOffset: scrollOffset,
                reduceMotion: isReduceMotionEnabled
            )

            ZStack(alignment: .top) {
                BONColor.backgroundPrimary
                    .ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        homeIntro(
                            metrics: metrics,
                            collapseProgress: collapseProgress,
                            reduceMotion: isReduceMotionEnabled
                        )
                            .frame(width: metrics.screenWidth, height: metrics.homeIntroHeight)

                        ForEach(HomeFeatureStoryKind.allCases) { kind in
                            HomeFeatureStoryPage(kind: kind, metrics: metrics)
                                .frame(width: metrics.screenWidth, height: metrics.storyPageHeight)
                                .scrollTransition(.interactive, axis: .vertical) { content, phase in
                                    let value = abs(phase.value)
                                    return content
                                        .opacity(isReduceMotionEnabled ? 1 : max(0.72, 1 - (value * 0.20)))
                                        .scaleEffect(isReduceMotionEnabled ? 1 : max(0.985, 1 - (value * 0.015)))
                                }
                        }
                    }
                    .scrollTargetLayout()
                    .frame(width: metrics.screenWidth, alignment: .top)
                    .offset(x: -metrics.scrollContentHorizontalCorrection)
                }
                .frame(width: metrics.screenWidth)
                .contentMargins(.horizontal, 0, for: .scrollContent)
                .scrollPosition($scrollPosition)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    max(0, geometry.contentOffset.y)
                } action: { _, newValue in
                    scrollOffset = newValue
                }
                .scrollTargetBehavior(
                    HomeStoryScrollTargetBehavior(
                        pageHeight: metrics.storyPageHeight,
                        pageCount: 1 + HomeFeatureStoryKind.allCases.count,
                        snapEnabled: initialScrollTarget.snapEnabled
                    )
                )
                .task(id: metrics.screenHeight) {
                    guard !didApplyInitialScrollTarget,
                          let targetY = initialScrollTarget.offset(metrics: metrics) else {
                        return
                    }

                    didApplyInitialScrollTarget = true
                    scrollOffset = targetY
                    scrollPosition.scrollTo(y: targetY)
                }

                HomeStoryChrome(
                    metrics: metrics,
                    collapseProgress: collapseProgress,
                    aiEntryNamespace: aiEntryNamespace,
                    isActiveTransitionSource: activeAIEntrySource == .cta,
                    onOpenAI: {
                        onOpenAI(.cta)
                    }
                )
            }
            .frame(width: metrics.screenWidth)
            .frame(minHeight: metrics.screenHeight, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .ignoresSafeArea(.container)
    }

    private func homeIntro(
        metrics: HomeFirstTimerLayoutMetrics,
        collapseProgress: CGFloat,
        reduceMotion: Bool
    ) -> some View {
        let featureFade = metrics.featureFadeProgress(collapseProgress: collapseProgress)

        return ZStack(alignment: .topLeading) {
            hero(metrics: metrics, collapseProgress: collapseProgress, reduceMotion: reduceMotion)
                .offset(x: metrics.heroOuterInset, y: metrics.heroOuterInset)

            Text("What you can do with BON Credit")
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: metrics.contentWidth, height: 17)
                .offset(x: metrics.contentMargin, y: 439)

            VStack(spacing: 12) {
                ForEach(HomeFirstTimerFixture.primaryFeatures) { feature in
                    BONFeatureCard(width: metrics.contentWidth, title: feature.title) {
                        artwork(for: feature.artwork)
                    }
                }
            }
            .frame(width: metrics.contentWidth)
            .opacity(1 - featureFade)
            .offset(y: reduceMotion ? 0 : -(featureFade * 34))
            .scaleEffect(reduceMotion ? 1 : 1 - (featureFade * 0.018), anchor: .top)
            .offset(x: metrics.contentMargin, y: 472)
        }
        .frame(width: metrics.screenWidth, height: metrics.homeIntroHeight, alignment: .top)
        .clipped()
    }

    private func hero(
        metrics: HomeFirstTimerLayoutMetrics,
        collapseProgress: CGFloat,
        reduceMotion: Bool
    ) -> some View {
        let dissolve = metrics.heroDissolveProgress(collapseProgress: collapseProgress)
        let shrink = metrics.heroShrinkProgress(collapseProgress: collapseProgress)

        return BONHeroPanel(width: metrics.heroWidth) {
            BONTopActionBar(
                width: metrics.heroContentWidth,
                modeAction: {
                    onOpenAI(.modePill)
                }
            )
            .modifier(
                HomeAIEntrySourceModifier(
                    namespace: aiEntryNamespace,
                    sourceID: AIChatEntrySource.modePill.transitionID,
                    isActive: activeAIEntrySource == .modePill
                )
            )
                .offset(y: 66)

            VStack(spacing: 0) {
                Text("Hi Marcus")
                    .font(BONTypography.zalando(size: 16, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: metrics.heroContentWidth, height: 22)

                Text("$5250/yr")
                    .font(BONTypography.geistPixel(size: 48))
                    .tracking(-0.96)
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: 205, height: 62)
                    .padding(.top, 20)

                heroMessage
                    .frame(width: 264, height: 48)
                    .padding(.top, 20)
            }
            .frame(width: metrics.heroContentWidth, height: 172, alignment: .top)
            .offset(y: 138)
        }
        .opacity(1 - dissolve)
        .blur(radius: reduceMotion ? 0 : dissolve * 3.2)
        .scaleEffect(reduceMotion ? 1 : 1 - (shrink * 0.08), anchor: .top)
        .offset(y: reduceMotion ? 0 : -(shrink * 64))
    }

    private var heroMessage: some View {
        VStack(spacing: 0) {
            (Text("going to ")
                + Text("credit card interest.")
                .bold())
            Text("That's $14 every single day, gone.")
        }
        .font(BONTypography.zalando(size: 16, weight: .regular))
        .foregroundStyle(BONColor.textPrimary)
        .multilineTextAlignment(.center)
        .lineSpacing(2)
    }

    @ViewBuilder
    private func artwork(for artwork: HomeFeatureCardContent.Artwork) -> some View {
        switch artwork {
        case .budgeting:
            Image("homeFeatureBudgetingArtwork")
                .resizable()
                .interpolation(.high)
                .scaledToFill()
        case .creditScore:
            HomeCreditScoreThumbnail()
        case .subscriptions:
            HomeSubscriptionThumbnail()
        }
    }
}

private struct HomeStoryChrome: View {
    let metrics: HomeFirstTimerLayoutMetrics
    let collapseProgress: CGFloat
    let aiEntryNamespace: Namespace.ID?
    let isActiveTransitionSource: Bool
    let onOpenAI: () -> Void

    var body: some View {
        let navHeight = metrics.navHeight(collapseProgress: collapseProgress)
        let navBottomEdge = metrics.navBottomEdge(collapseProgress: collapseProgress)

        ZStack(alignment: .top) {
            BONCTAPill(title: "Talk with AI", action: onOpenAI)
                .modifier(
                    HomeAIEntrySourceModifier(
                        namespace: aiEntryNamespace,
                        sourceID: AIChatEntrySource.cta.transitionID,
                        isActive: isActiveTransitionSource
                    )
                )
                .scaleEffect(metrics.ctaScale(collapseProgress: collapseProgress))
                .position(
                    x: metrics.screenWidth / 2,
                    y: metrics.ctaCenterY(collapseProgress: collapseProgress)
                )

            BONBottomNav(
                selectedID: "home",
                items: HomeFirstTimerFixture.navItems,
                width: metrics.contentWidth,
                variant: collapseProgress >= 1 ? .compact : .expanded,
                collapseProgress: collapseProgress
            )
            .position(
                x: metrics.screenWidth / 2,
                y: navBottomEdge - (navHeight / 2)
            )
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
    }
}

private struct HomeAIEntrySourceModifier: ViewModifier {
    let namespace: Namespace.ID?
    let sourceID: String
    let isActive: Bool

    func body(content: Content) -> some View {
        if let namespace {
            content.matchedTransitionSource(id: sourceID, in: namespace)
        } else {
            content
        }
    }
}

private enum HomeFeatureStoryKind: String, CaseIterable, Identifiable {
    case budgeting
    case creditScore
    case cashAdvance

    var id: String { rawValue }
}

private enum HomeInitialScrollTarget {
    case none
    case offset(CGFloat)
    case storyPage(Int)

    static func fromLaunchArguments() -> HomeInitialScrollTarget {
        let arguments = ProcessInfo.processInfo.arguments

        if let index = arguments.firstIndex(of: "-BONInitialScrollY"),
           arguments.indices.contains(index + 1),
           let value = Double(arguments[index + 1]) {
            return .offset(CGFloat(value))
        }

        if let index = arguments.firstIndex(of: "-BONStoryPage"),
           arguments.indices.contains(index + 1) {
            switch arguments[index + 1].lowercased() {
            case "budgeting", "0":
                return .storyPage(0)
            case "credit", "credit-score", "1":
                return .storyPage(1)
            case "cash", "cash-advance", "2":
                return .storyPage(2)
            default:
                return .none
            }
        }

        return .none
    }

    func offset(metrics: HomeFirstTimerLayoutMetrics) -> CGFloat? {
        switch self {
        case .none:
            return nil
        case .offset(let value):
            return max(0, value)
        case .storyPage(let index):
            return metrics.homeIntroHeight + (CGFloat(max(0, index)) * metrics.storyPageHeight)
        }
    }

    var snapEnabled: Bool {
        switch self {
        case .offset:
            return false
        case .none, .storyPage:
            return true
        }
    }
}

private struct HomeFeatureStoryPage: View {
    let kind: HomeFeatureStoryKind
    let metrics: HomeFirstTimerLayoutMetrics

    var body: some View {
        ZStack(alignment: .topLeading) {
            BONColor.backgroundPrimary

            switch kind {
            case .budgeting:
                budgetingContent
            case .creditScore:
                creditScoreContent
            case .cashAdvance:
                cashAdvanceContent
            }
        }
        .frame(width: metrics.screenWidth, height: metrics.storyPageHeight)
        .accessibilityElement(children: .contain)
    }

    private var budgetingContent: some View {
        ZStack(alignment: .topLeading) {
            storyTitle("Free Smart Budgeting", x: 70, width: 249)

            HomeBudgetHeatmapChart()
                .frame(width: 310, height: 156)
                .position(x: metrics.storyX(40) + 155, y: 232 + 78)

            HomeBudgetRows()
                .frame(width: 310, height: 208)
                .position(x: metrics.storyX(40) + 155, y: 428 + 104)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.94),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: metrics.baselineWidth, height: 104)
                .position(x: metrics.storyX(0) + 195, y: 590 + 52)
                .allowsHitTesting(false)

            BONStoryPrimaryButton(title: "Link credit cards")
                .frame(width: 310, height: 48)
                .position(x: metrics.storyX(40) + 155, y: 660 + 24)

            HomeStoryChevron()
                .position(x: metrics.storyX(203) + 8, y: 741 + 4)
        }
    }

    private var creditScoreContent: some View {
        ZStack(alignment: .topLeading) {
            storyTitle("Lift your Credit Score", x: 73, width: 243)

            HomeCreditScoreStoryRing(metrics: metrics)

            Text("I tell you why it moved and what\nto do next.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .frame(width: 248, height: 48)
                .position(x: metrics.storyX(78) + 124, y: 495 + 24)

            BONStoryPrimaryButton(title: "Link credit cards")
                .frame(width: 310, height: 48)
                .position(x: metrics.storyX(40) + 155, y: 660 + 24)

            HomeStoryChevron()
                .position(x: metrics.storyX(203) + 8, y: 741 + 4)
        }
    }

    private var cashAdvanceContent: some View {
        ZStack(alignment: .topLeading) {
            storyTitle("Get instant loan", x: 44, width: 302)

            VStack(spacing: 0) {
                Text("upto")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: 196, height: 15)

                Text("$10,000")
                    .font(BONTypography.geistPixel(size: 48))
                    .tracking(-0.96)
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: 196, height: 73)

                Text("instantly available for you")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: 196, height: 15)
            }
            .frame(width: 196, height: 111)
            .position(x: metrics.storyX(97) + 98, y: 235 + 55.5)

            VStack(spacing: 12) {
                HomeCashBenefitPill(title: "Zero documentation needed")
                HomeCashBenefitPill(title: "Zero hidden charges ever")
                HomeCashBenefitPill(title: "Instantly disbursed")
            }
            .frame(width: 260, height: 153)
            .position(x: metrics.storyX(65) + 130, y: 394 + 76.5)

            HomePartnerBadge()
                .frame(width: 186, height: 31)
                .position(x: metrics.storyX(102) + 93, y: 613 + 15.5)

            BONStoryPrimaryButton(title: "Get now")
                .frame(width: 310, height: 48)
                .position(x: metrics.storyX(40) + 155, y: 660 + 24)

            HomeStoryChevron()
                .position(x: metrics.storyX(203) + 8, y: 741 + 4)
        }
    }

    private func storyTitle(_ title: String, x: CGFloat, width: CGFloat) -> some View {
        Text(title)
            .font(BONTypography.zalando(size: 24, weight: .semibold))
            .foregroundStyle(BONColor.textPrimary)
            .multilineTextAlignment(.center)
            .frame(width: width, height: 29)
            .lineLimit(1)
            .minimumScaleFactor(0.84)
            .position(x: metrics.storyX(x) + (width / 2), y: 171 + 14.5)
    }
}

private struct BONStoryPrimaryButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(BONColor.accentLime)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.black, lineWidth: 1.2)
                        )
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

private struct HomeStoryChevron: View {
    var body: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 16, weight: .light))
            .foregroundStyle(BONColor.textPrimary)
            .frame(width: 16, height: 8)
            .accessibilityHidden(true)
    }
}

private struct HomeBudgetHeatmapChart: View {
    private let values: [Int] = [
        4, 9, 8, 9, 6, 0, 0, 11, 14, 11, 10, 8, 0, 10, 9, 8,
        8, 10, 9, 7, 6, 8, 6, 5, 5, 5, 5, 0, 8, 9, 11
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(values.indices, id: \.self) { column in
                ForEach(0..<values[column], id: \.self) { row in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(color(for: row, total: values[column]))
                        .frame(width: 8, height: 8)
                        .position(
                            x: CGFloat(column * 10) + 4,
                            y: CGFloat(132 - (row * 10))
                        )
                }
            }

            Text("Apr 05")
                .font(BONTypography.zalando(size: 10, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: 32, height: 12)
                .position(x: 16, y: 150)

            Text("Apr 20")
                .font(BONTypography.zalando(size: 10, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: 32, height: 12)
                .position(x: 154, y: 150)

            Text("May 05")
                .font(BONTypography.zalando(size: 10, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: 44, height: 12)
                .position(x: 293, y: 150)
        }
    }

    private func color(for row: Int, total: Int) -> Color {
        if row >= max(0, total - 2), total >= 9 {
            return Color(red: 1.0, green: 0.30, blue: 0.36)
        }

        if row >= 7 {
            return Color(red: 1.0, green: 0.82, blue: 0.78).opacity(0.76)
        }

        if row >= 4 {
            return Color(red: 1.0, green: 0.95, blue: 0.58).opacity(0.72)
        }

        return BONColor.accentLime
    }
}

private struct HomeBudgetRows: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            HomeBudgetRow(
                icon: "fork.knife",
                title: "Dining",
                amount: "$353",
                trend: .up("$112"),
                opacity: 1
            )
            .position(x: 155, y: 12)

            HomeBudgetRow(
                icon: "lightbulb",
                title: "Utilities",
                amount: "$120",
                trend: .flat,
                opacity: 1
            )
            .position(x: 155, y: 68)

            HomeBudgetRow(
                icon: "gamecontroller",
                title: "Entertainment",
                amount: "$90",
                trend: .down("$28"),
                opacity: 1
            )
            .position(x: 155, y: 124)

            HomeBudgetRow(
                icon: "diamond",
                title: "Others",
                amount: "$45",
                trend: .down("$65"),
                opacity: 0.10
            )
            .position(x: 155, y: 180)

            ForEach([40, 96, 152, 208], id: \.self) { y in
                Rectangle()
                    .fill(BONColor.divider)
                    .frame(width: 310, height: 1)
                    .offset(x: 0, y: CGFloat(y))
            }
        }
    }
}

private struct HomeBudgetRow: View {
    enum Trend {
        case up(String)
        case down(String)
        case flat
    }

    let icon: String
    let title: String
    let amount: String
    let trend: Trend
    let opacity: CGFloat

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: 24, height: 24)

            Text(title)
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)

            Spacer()

            Text(amount)
                .font(BONTypography.zalando(size: 16, weight: .bold))
                .foregroundStyle(BONColor.textPrimary)

            trendView
        }
        .frame(width: 310, height: 24)
        .opacity(opacity)
    }

    @ViewBuilder
    private var trendView: some View {
        switch trend {
        case .up(let value):
            HStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 10, weight: .regular))
                Text(value)
                    .font(BONTypography.zalando(size: 12, weight: .regular))
            }
            .foregroundStyle(Color(red: 0.94, green: 0.20, blue: 0.22).opacity(0.82))
            .frame(width: 42, alignment: .trailing)
        case .down(let value):
            HStack(spacing: 4) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 10, weight: .regular))
                Text(value)
                    .font(BONTypography.zalando(size: 12, weight: .regular))
            }
            .foregroundStyle(BONColor.success.opacity(0.82))
            .frame(width: 42, alignment: .trailing)
        case .flat:
            Text("-")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: 42, alignment: .trailing)
        }
    }
}

private struct HomeCreditScoreStoryRing: View {
    let metrics: HomeFirstTimerLayoutMetrics

    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .trim(from: 0.54, to: 0.96)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.87, blue: 0.75),
                            Color(red: 1.0, green: 0.46, blue: 0.16),
                            Color(red: 1.0, green: 0.76, blue: 0.49)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 78, lineCap: .butt)
                )
                .rotationEffect(.degrees(14))
                .frame(width: 563, height: 563)
                .position(x: metrics.storyX(-87) + 281.5, y: 170 + 62 + 281.5 + 38)

            Rectangle()
                .fill(Color(red: 1.0, green: 0.46, blue: 0.02))
                .frame(width: 2, height: 86)
                .rotationEffect(.degrees(31))
                .position(x: metrics.storyX(326), y: 300)

            Text("+38 pts")
                .font(BONTypography.zalando(size: 24, weight: .regular))
                .foregroundStyle(Color(red: 1.0, green: 0.39, blue: 0.12))
                .frame(width: 90, height: 28)
                .position(x: metrics.storyX(151) + 43.5, y: 365 + 14)
        }
    }
}

private struct HomeCashBenefitPill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(BONTypography.zalando(size: 16, weight: .regular))
            .foregroundStyle(BONColor.textPrimary)
            .frame(width: 260, height: 43)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(red: 0.985, green: 0.985, blue: 0.985))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(BONColor.borderSubtle, lineWidth: 1)
                    )
            )
    }
}

private struct HomePartnerBadge: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(BONColor.accentLime)

            Text("Partnered with Moneylion")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.accentLime)
        }
        .frame(width: 186, height: 31)
        .background(
            Capsule(style: .continuous)
                .fill(Color.black)
        )
    }
}

private struct HomeFirstTimerLayoutMetrics {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let baselineWidth: CGFloat = 390
    let baselineHeight: CGFloat = 845
    let contentMargin: CGFloat = 24
    let heroOuterInset: CGFloat = 8
    let scrollContentHorizontalCorrection: CGFloat = 8

    init(size: CGSize) {
        screenWidth = max(320, size.width)
        screenHeight = max(845, size.height)
    }

    var homeIntroHeight: CGFloat {
        screenHeight
    }

    var storyPageHeight: CGFloat {
        screenHeight
    }

    var storyOriginX: CGFloat {
        (screenWidth - baselineWidth) / 2
    }

    var contentWidth: CGFloat {
        max(0, screenWidth - (contentMargin * 2))
    }

    var heroWidth: CGFloat {
        max(0, screenWidth - (heroOuterInset * 2))
    }

    var heroContentWidth: CGFloat {
        max(0, heroWidth - 48)
    }

    func storyX(_ figmaX: CGFloat) -> CGFloat {
        storyOriginX + figmaX
    }

    func navHeight(collapseProgress: CGFloat) -> CGFloat {
        interpolate(expanded: 64, compact: 44, progress: collapseProgress)
    }

    func ctaCenterY(collapseProgress: CGFloat) -> CGFloat {
        interpolate(
            expanded: 8 + 342 + 16.5,
            compact: max(74 + 16.5, safeTopPinnedCTACenterY),
            progress: collapseProgress
        )
    }

    func ctaScale(collapseProgress: CGFloat) -> CGFloat {
        1 - (sin(collapseProgress * .pi) * 0.045)
    }

    func navBottomEdge(collapseProgress: CGFloat) -> CGFloat {
        interpolate(expanded: screenHeight - 48, compact: screenHeight - 20, progress: collapseProgress)
    }

    func chromeCollapseProgress(scrollOffset: CGFloat, reduceMotion: Bool) -> CGFloat {
        let rawProgress = scrollOffset / max(1, screenHeight * 0.48)
        return clamp(rawProgress)
    }

    func heroDissolveProgress(collapseProgress: CGFloat) -> CGFloat {
        smoothstep(edge0: 0.00, edge1: 0.58, value: collapseProgress)
    }

    func heroShrinkProgress(collapseProgress: CGFloat) -> CGFloat {
        smoothstep(edge0: 0.00, edge1: 0.72, value: collapseProgress)
    }

    func featureFadeProgress(collapseProgress: CGFloat) -> CGFloat {
        smoothstep(edge0: 0.34, edge1: 0.86, value: collapseProgress)
    }

    private func interpolate(expanded: CGFloat, compact: CGFloat, progress: CGFloat) -> CGFloat {
        expanded + ((compact - expanded) * clamp(progress))
    }

    private var safeTopPinnedCTACenterY: CGFloat {
        58 + 16.5
    }

    private func smoothstep(edge0: CGFloat, edge1: CGFloat, value: CGFloat) -> CGFloat {
        guard edge0 != edge1 else {
            return clamp(value)
        }

        let x = clamp((value - edge0) / (edge1 - edge0))
        return x * x * (3 - (2 * x))
    }

    private func clamp(_ value: CGFloat) -> CGFloat {
        min(1, max(0, value))
    }
}

private struct HomeStoryScrollTargetBehavior: ScrollTargetBehavior {
    let pageHeight: CGFloat
    let pageCount: Int
    let snapEnabled: Bool

    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        guard snapEnabled, context.axes.contains(.vertical) else {
            return
        }

        let resolvedPageHeight = max(1, min(pageHeight, context.containerSize.height))
        let maxPageIndex = max(0, pageCount - 1)
        let snapBias = resolvedPageHeight * 0.74
        let proposedPage = Int(((target.rect.minY + snapBias) / resolvedPageHeight).rounded(.down))
        let pageIndex = min(maxPageIndex, max(0, proposedPage))
        let snappedY = CGFloat(pageIndex) * resolvedPageHeight
        let maxOffset = max(0, context.contentSize.height - context.containerSize.height)

        target.rect.origin.y = min(snappedY, maxOffset)
        target.anchor = .top
    }

    @available(iOS 18.4, *)
    func properties(context: PropertiesContext) -> Properties {
        var properties = Properties()
        properties.limitsScrolls = true
        return properties
    }
}

private struct HomeCreditScoreThumbnail: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.31, blue: 0.06),
                            Color(red: 1.0, green: 0.39, blue: 0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Circle()
                .trim(from: 0.08, to: 0.60)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.82),
                            Color(red: 1.0, green: 0.73, blue: 0.45).opacity(0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 28, lineCap: .round)
                )
                .frame(width: 190, height: 190)
                .offset(x: -18, y: 62)

            Rectangle()
                .fill(Color(red: 1.0, green: 0.73, blue: 0.18))
                .frame(width: 2, height: 58)
                .rotationEffect(.degrees(31))
                .offset(x: 49, y: -13)
        }
    }
}

private struct HomeSubscriptionThumbnail: View {
    private let symbols = ["sparkles", "creditcard", "iphone", "play.rectangle", "music.note", "house"]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(red: 0.965, green: 0.977, blue: 0.965))

            LazyVGrid(columns: [GridItem(.fixed(42)), GridItem(.fixed(42))], spacing: 8) {
                ForEach(symbols, id: \.self) { symbol in
                    Image(systemName: symbol)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(BONColor.textPrimary)
                        .frame(width: 42, height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
                        )
                }
            }
            .frame(width: 92, height: 142)
        }
    }
}

#Preview {
    HomeFirstTimerClickedView()
}
