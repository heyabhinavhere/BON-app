import SwiftUI

struct HomeFirstTimerClickedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var homeNamespace

    @State private var surface = HomeFirstTimerLaunch.surface
    @State private var dashboardScrollPosition = ScrollPosition(idType: Never.self)
    @State private var dashboardScrollOffset: CGFloat = 0
    @State private var didApplyInitialDashboardOffset = false
    @State private var budgetingCardFrame: CGRect = .zero
    @State private var budgetingTransitionProgress: CGFloat = 0
    @State private var budgetingTransition: BudgetingTransition?
    @State private var aiReportSourceFrame: CGRect = .zero
    @State private var aiReportTransitionProgress: CGFloat = 0
    @State private var aiReportTransition: AIReportTransition?
    @State private var didRunAutoAIReportMorph = false

    var aiEntryNamespace: Namespace.ID?
    var activeAIEntrySource: AIChatEntrySource = .cta
    var onOpenAI: (AIChatEntrySource) -> Void = { _ in }
    var onOpenCredit: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeFirstTimerMetrics(
                size: proxy.size,
                safeArea: proxy.safeAreaInsets
            )

            ZStack {
                FirstTimerBackground(showsAIGlow: surface == .aiLanding)

                if surface == .aiLanding {
                    FirstTimerAIReportView(
                        metrics: metrics,
                        namespace: homeNamespace,
                        aiEntryNamespace: aiEntryNamespace,
                        isActiveAITransitionSource: activeAIEntrySource == .cta,
                        onHome: showHome,
                        onAskAI: {
                            onOpenAI(.cta)
                        }
                    )
                    .transition(reportTransition)
                    .allowsHitTesting(aiReportTransition == nil)
                    .accessibilityHidden(aiReportTransition != nil)
                    .zIndex(2)
                }

                if surface == .home {
                    FirstTimerHomeDashboardView(
                        metrics: metrics,
                        namespace: homeNamespace,
                        scrollPosition: $dashboardScrollPosition,
                        scrollOffset: $dashboardScrollOffset,
                        didApplyInitialOffset: $didApplyInitialDashboardOffset,
                        initialOffset: HomeFirstTimerLaunch.dashboardScrollOffset,
                        onBudgeting: showBudgeting,
                        onShowAIReport: showAIReport,
                        onOpenCredit: onOpenCredit
                    )
                    .opacity(1)
                    .allowsHitTesting(surface == .home && budgetingTransition == nil && aiReportTransition == nil)
                    .accessibilityHidden(surface != .home || budgetingTransition != nil || aiReportTransition != nil)
                    .transition(homeTransition)
                    .zIndex(1)
                }

                if surface == .budgeting {
                    FirstTimerBudgetingView(
                        metrics: metrics,
                        onClose: showHome
                    )
                    .transition(budgetingViewTransition)
                    .zIndex(3)
                }

                if budgetingTransition != nil {
                    FirstTimerBudgetingTransitionOverlay(
                        metrics: metrics,
                        sourceFrame: budgetingCardFrame,
                        progress: reduceMotion ? 1 : budgetingTransitionProgress
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .zIndex(5)
                }

                if let aiReportTransition {
                    FirstTimerAIReportMorphOverlay(
                        metrics: metrics,
                        sourceFrame: aiReportSourceFrame,
                        progress: reduceMotion ? 1 : aiReportTransitionProgress,
                        isClosing: aiReportTransition == .closing
                    )
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                    .zIndex(6)
                }
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
            .coordinateSpace(name: "firstTimerHomeRoot")
            .onPreferenceChange(FirstTimerBudgetingCardFrameKey.self) { frame in
                guard frame.width > 0, frame.height > 0 else {
                    return
                }

                budgetingCardFrame = frame
            }
            .onPreferenceChange(FirstTimerAIReportFrameKey.self) { frame in
                guard frame.width > 0, frame.height > 0 else {
                    return
                }

                aiReportSourceFrame = frame
            }
            .task(id: aiReportSourceFrame) {
                guard HomeFirstTimerLaunch.autoAIReportMorph,
                      !didRunAutoAIReportMorph,
                      surface == .home,
                      aiReportSourceFrame.width > 0,
                      aiReportSourceFrame.height > 0 else {
                    return
                }

                didRunAutoAIReportMorph = true
                try? await Task.sleep(nanoseconds: 900_000_000)
                showAIReport()
            }
        }
        .ignoresSafeArea()
    }

    private var reportTransition: AnyTransition {
        reduceMotion ? .opacity : .identity
    }

    private var homeTransition: AnyTransition {
        reduceMotion ? .opacity : .identity
    }

    private var budgetingViewTransition: AnyTransition {
        if reduceMotion {
            return .opacity
        }

        return .identity
    }

    private func showHome() {
        Task { @MainActor in
            BONHaptics.selection()
            let wasBudgeting = surface == .budgeting
            let wasAIReport = surface == .aiLanding

            if wasBudgeting, !reduceMotion {
                budgetingTransition = .closing
                budgetingTransitionProgress = 1
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    surface = .home
                }

                withAnimation(budgetingMorphAnimation) {
                    budgetingTransitionProgress = 0
                }

                try? await Task.sleep(nanoseconds: 760_000_000)
                clearBudgetingTransition()
                return
            }

            if wasAIReport, !reduceMotion {
                aiReportTransition = .closing
                aiReportTransitionProgress = 1
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    surface = .home
                }

                withAnimation(aiReportMorphAnimation) {
                    aiReportTransitionProgress = 0
                }

                try? await Task.sleep(nanoseconds: 640_000_000)
                clearAIReportTransition()
                return
            }

            withAnimation(closeToHomeAnimation) {
                surface = .home
            }
        }
    }

    private func showAIReport() {
        Task { @MainActor in
            guard surface == .home, aiReportTransition == nil else {
                return
            }

            BONHaptics.selection()

            guard !reduceMotion else {
                withAnimation(screenTransitionAnimation) {
                    surface = .aiLanding
                }
                return
            }

            aiReportTransition = .opening
            aiReportTransitionProgress = 0

            withAnimation(aiReportMorphAnimation) {
                aiReportTransitionProgress = 1
            }

            try? await Task.sleep(nanoseconds: 640_000_000)
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                surface = .aiLanding
            }
            clearAIReportTransition()

            if HomeFirstTimerLaunch.autoAIReportClose {
                try? await Task.sleep(nanoseconds: 760_000_000)
                showHome()
            }
        }
    }

    private func showBudgeting() {
        Task { @MainActor in
            guard surface == .home, budgetingTransition == nil else {
                return
            }

            BONHaptics.impact(.light)

            guard !reduceMotion else {
                withAnimation(budgetingMorphAnimation) {
                    surface = .budgeting
                }
                return
            }

            budgetingTransition = .opening
            budgetingTransitionProgress = 0

            withAnimation(budgetingMorphAnimation) {
                budgetingTransitionProgress = 1
            }

            try? await Task.sleep(nanoseconds: 760_000_000)
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                surface = .budgeting
            }
            clearBudgetingTransition()
        }
    }

    @MainActor
    private func clearBudgetingTransition() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            budgetingTransition = nil
        }
    }

    @MainActor
    private func clearAIReportTransition() {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            aiReportTransition = nil
        }
    }

    private var closeToHomeAnimation: Animation {
        screenTransitionAnimation
    }

    private var screenTransitionAnimation: Animation {
        reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.matchedMorph
    }

    private var aiReportMorphAnimation: Animation {
        reduceMotion ? BONMotion.reducedMotionFallback : .timingCurve(0.24, 0.0, 0.14, 1.0, duration: 0.56)
    }

    private var budgetingMorphAnimation: Animation {
        reduceMotion ? BONMotion.reducedMotionFallback : .timingCurve(0.28, 0.0, 0.12, 1.0, duration: 0.68)
    }
}

private enum BudgetingTransition {
    case opening
    case closing
}

private enum AIReportTransition {
    case opening
    case closing
}

private struct FirstTimerBudgetingCardFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        guard next.width > 0, next.height > 0 else {
            return
        }

        value = next
    }
}

private struct FirstTimerAIReportFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        guard next.width > 0, next.height > 0 else {
            return
        }

        value = next
    }
}

private enum HomeFirstTimerSurface: String {
    case aiLanding
    case home
    case budgeting
}

private enum HomeFirstTimerLaunch {
    static let surface: HomeFirstTimerSurface = {
        let arguments = ProcessInfo.processInfo.arguments

        if let index = arguments.firstIndex(of: "-BONHomeFirstTimerState"),
           arguments.indices.contains(index + 1) {
            switch arguments[index + 1].lowercased() {
            case "home", "dashboard", "home-scrolled":
                return .home
            case "budgeting":
                return .budgeting
            case "ai", "ai-landing", "report":
                return .aiLanding
            default:
                break
            }
        }

        return .aiLanding
    }()

    static let dashboardScrollOffset: CGFloat = {
        let arguments = ProcessInfo.processInfo.arguments

        if let index = arguments.firstIndex(of: "-BONHomeScrollY"),
           arguments.indices.contains(index + 1),
           let value = Double(arguments[index + 1]) {
            return max(0, CGFloat(value))
        }

        if let index = arguments.firstIndex(of: "-BONHomeFirstTimerState"),
           arguments.indices.contains(index + 1),
           arguments[index + 1].lowercased() == "home-scrolled" {
            return 292
        }

        return 0
    }()

    static let reportScrollOffset: CGFloat = {
        let arguments = ProcessInfo.processInfo.arguments

        if let index = arguments.firstIndex(of: "-BONReportScrollY"),
           arguments.indices.contains(index + 1),
           let value = Double(arguments[index + 1]) {
            return max(0, CGFloat(value))
        }

        return 0
    }()

    static let autoAIReportMorph = ProcessInfo.processInfo.arguments.contains("-BONAutoAIReportMorph")
    static let autoAIReportClose = ProcessInfo.processInfo.arguments.contains("-BONAutoAIReportClose")

}

private struct HomeFirstTimerMetrics {
    let size: CGSize
    let safeArea: EdgeInsets

    let baselineWidth: CGFloat = 390

    var screenWidth: CGFloat { size.width }
    var screenHeight: CGFloat { size.height }
    var safeTop: CGFloat { max(safeArea.top, 54) }
    var safeBottom: CGFloat { max(safeArea.bottom, 34) }
    var horizontalMargin: CGFloat { 24 }
    var contentWidth: CGFloat { max(310, screenWidth - (horizontalMargin * 2)) }
    var reportContentWidth: CGFloat { min(342, max(310, screenWidth - 48)) }
    var compactColumn: CGFloat { min(310, screenWidth - 80) }
    var topControlCenterY: CGFloat { safeTop + 38 }
    var bottomChromeBottom: CGFloat { safeBottom + 16 }
    var expandedNavBottom: CGFloat { safeBottom + 46 }
    var compactNavBottom: CGFloat { safeBottom + 22 }
    var composerBottom: CGFloat { safeBottom + 16 }

    func centerX(_ baselineX: CGFloat) -> CGFloat {
        (screenWidth / 2) + (baselineX - (baselineWidth / 2))
    }
}

private func firstTimerSmoothStep(_ value: CGFloat) -> CGFloat {
    let x = min(1, max(0, value))
    return x * x * (3 - (2 * x))
}

private func firstTimerRangeProgress(_ value: CGFloat, start: CGFloat, end: CGFloat) -> CGFloat {
    guard end > start else {
        return firstTimerSmoothStep(value)
    }

    return firstTimerSmoothStep((value - start) / (end - start))
}

private func firstTimerLerp(_ start: CGFloat, _ end: CGFloat, _ progress: CGFloat) -> CGFloat {
    start + ((end - start) * min(1, max(0, progress)))
}

private struct FirstTimerBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var showsAIGlow = false

    var body: some View {
        ZStack {
            BONColor.backgroundPrimary

            if showsAIGlow {
                BONSiriEdgeGlow(isActive: !reduceTransparency)
                    .opacity(reduceTransparency ? 0 : 0.88)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - AI Landing

private struct FirstTimerAIReportView: View {
    @State private var scrollPosition = ScrollPosition(idType: Never.self)
    @State private var didApplyInitialOffset = false

    let metrics: HomeFirstTimerMetrics
    let namespace: Namespace.ID
    let aiEntryNamespace: Namespace.ID?
    let isActiveAITransitionSource: Bool
    let onHome: () -> Void
    let onAskAI: () -> Void

    var body: some View {
        let reportWidth = metrics.reportContentWidth

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(Color.white)
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: metrics.safeTop + 109)

                    Text("Hi Marcus, I reviewed your credit\nreport here’s what I found")
                        .font(BONTypography.zalando(size: 16, weight: .regular))
                        .foregroundStyle(BONColor.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .frame(width: reportWidth, height: 44)

                    HStack(spacing: 12) {
                        FirstTimerCreditScoreCard(width: (reportWidth - 12) / 2)
                        FirstTimerLiabilitiesCard(width: (reportWidth - 12) / 2)
                    }
                    .frame(width: reportWidth)
                    .padding(.top, 22)

                    FirstTimerOpenCardsPanel(width: reportWidth)
                        .padding(.top, 12)

                    FirstTimerInsightBlock(width: reportWidth)
                        .padding(.top, 46)

                    VStack(alignment: .trailing, spacing: 12) {
                        FirstTimerSuggestionBubble("Yes, help me with this card", width: min(202, reportWidth * 0.68))
                        FirstTimerSuggestionBubble("What about my credit score?", width: min(215, reportWidth * 0.68))
                        FirstTimerSuggestionBubble("What else you could do for me?", width: min(232, reportWidth * 0.72))
                    }
                    .frame(width: reportWidth, alignment: .trailing)
                    .padding(.top, 23)

                    FirstTimerChatComposer(
                        width: reportWidth,
                        placeholder: "Ask BON Credit...",
                        action: onAskAI
                    )
                    .modifier(
                        HomeAIEntrySourceModifier(
                            namespace: aiEntryNamespace,
                            sourceID: AIChatEntrySource.cta.transitionID,
                            isActive: isActiveAITransitionSource
                        )
                    )
                    .padding(.top, 76)

                    Color.clear
                        .frame(height: metrics.safeBottom + 16)
                }
                .frame(width: metrics.screenWidth)
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .scrollPosition($scrollPosition)
            .task(id: metrics.screenHeight) {
                guard !didApplyInitialOffset,
                      HomeFirstTimerLaunch.reportScrollOffset > 0 else {
                    return
                }

                didApplyInitialOffset = true
                scrollPosition.scrollTo(y: HomeFirstTimerLaunch.reportScrollOffset)
            }

            AIChatTopScrim()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.container, edges: .top)
                .allowsHitTesting(false)

            FirstTimerTopChrome(
                metrics: metrics,
                center: .linkCards,
                left: .menu,
                right: .home,
                namespace: namespace,
                onCenter: {},
                onLeft: {},
                onRight: onHome
            )

        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        .matchedGeometryEffect(id: "first-timer-ai-report-surface", in: namespace)
        .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
    }
}

private struct FirstTimerCreditScoreCard: View {
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            FirstTimerCardBackground(cornerRadius: 24)

            Text("Credit score")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: width, height: 15)
                .offset(y: 16)

            Image("firstTimerCreditScoreGraphic")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: width * 1.44, height: 176)
                .frame(width: width, height: 156, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Text("614")
                    .font(BONTypography.geistPixel(size: 40))
                    .tracking(-3.2)
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(height: 49)

                Color.clear
                    .frame(height: 16)
            }
            .frame(width: width, height: 156)
        }
        .frame(width: width, height: 156)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Credit score 614")
    }
}

private struct FirstTimerLiabilitiesCard: View {
    let width: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Text("Liabilites")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .frame(height: 15)
                .padding(.top, 16)

            Spacer(minLength: 0)

            Text("8")
                .font(BONTypography.geistPixel(size: 48))
                .tracking(-0.96)
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 58)
                .padding(.top, 1)

            Text("no. of open accounts")
                .font(BONTypography.zalando(size: 12, weight: .light))
                .foregroundStyle(BONColor.textPrimary)
                .padding(.top, 0)

            Text("(12 closed accounts)")
                .font(BONTypography.zalando(size: 10, weight: .light))
                .foregroundStyle(BONColor.textTertiary)
                .padding(.top, 3)

            Color.clear
                .frame(height: 20)
        }
        .frame(width: width, height: 156)
        .background {
            FirstTimerCardBackground(cornerRadius: 24)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Liabilities. 8 open accounts. 12 closed accounts.")
    }
}

private struct FirstTimerCardBackground: View {
    var cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
    }
}

private struct FirstTimerCreditGauge: View {
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.54, to: 0.96)
                .stroke(BONColor.lime50, style: StrokeStyle(lineWidth: 37, lineCap: .butt))
                .rotationEffect(.degrees(8))
                .blur(radius: 1.5)

            Circle()
                .trim(from: 0.54, to: 0.86)
                .stroke(
                    AngularGradient(
                        colors: [
                            BONColor.lime500,
                            BONColor.lime300,
                            BONColor.lime100
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 37, lineCap: .butt)
                )
                .rotationEffect(.degrees(8))
                .shadow(color: BONColor.lime500.opacity(0.48), radius: 10, x: 0, y: 0)

            Rectangle()
                .fill(BONColor.lime500)
                .frame(width: 1.4, height: 45)
                .rotationEffect(.degrees(27))
                .offset(x: 50, y: -15)
        }
        .mask {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 92, alignment: .top)
        }
    }
}

private struct FirstTimerOpenCardsPanel: View {
    let width: CGFloat

    private let cards = [
        CreditCardRowData(issuer: "Chase freedom u...", amount: "$5,480", detail: "XX 5675 | 91% utilized", minPayment: "$185 min.", logoAsset: "firstTimerCardLogoChase"),
        CreditCardRowData(issuer: "Amex blue Cash P...", amount: "$4,983", detail: "XX 1234 | 43% utilized", minPayment: "$134 min.", logoAsset: "firstTimerCardLogoAmex"),
        CreditCardRowData(issuer: "Discover It Card", amount: "$3,900", detail: "XX 4321 | 28% utilized", minPayment: "$91 min.", logoAsset: "firstTimerCardLogoDiscover"),
        CreditCardRowData(issuer: "Capital One Quick...", amount: "$2,320", detail: "XX 8765 | 04% utilized", minPayment: "$35 min.", logoAsset: "firstTimerCardLogoCapitalOne")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Text("Open credit cards")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .frame(height: 15)
                    .padding(.top, 16)

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total outstanding balance")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(BONColor.textPrimary)

                        Text("$26,893")
                            .font(BONTypography.geistPixel(size: 32))
                            .tracking(-0.64)
                            .foregroundStyle(BONColor.textPrimary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 10) {
                        Text("Costing interest")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(BONColor.textPrimary)

                        Text("~ $285/mo")
                            .font(BONTypography.zalando(size: 16, weight: .light))
                            .foregroundStyle(Color.red)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)

                FirstTimerDashedDivider()
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                    .padding(.top, 18)

                VStack(spacing: 0) {
                    ForEach(Array(cards.prefix(3))) { card in
                        FirstTimerCreditCardRow(card: card)

                        if card.id != cards.prefix(3).last?.id {
                            Divider()
                                .overlay(BONColor.divider)
                                .padding(.leading, 56)
                                .padding(.trailing, 16)
                        }
                    }
                }
                .padding(.top, 10)

                Spacer(minLength: 0)
            }

            Button {
                BONHaptics.selection()
            } label: {
                HStack(spacing: 7) {
                    Text("view all")
                        .font(BONTypography.zalando(size: 14, weight: .light))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .regular))
                }
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: 96, height: 32)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.98))
                        .overlay {
                            Capsule(style: .continuous)
                                .stroke(BONColor.borderSubtle, lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 4)
                )
            }
            .buttonStyle(BONScaleButtonStyle())
            .offset(y: 16)
        }
        .frame(width: width, height: 394)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        }
    }
}

private struct CreditCardRowData: Identifiable {
    let id = UUID()
    let issuer: String
    let amount: String
    let detail: String
    let minPayment: String
    let logoAsset: String
}

private struct FirstTimerCreditCardRow: View {
    let card: CreditCardRowData

    var body: some View {
        HStack(spacing: 12) {
            Image(card.logoAsset)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                Text(card.issuer)
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(BONColor.textPrimary)
                    .tracking(0.32)
                    .lineLimit(1)

                Text(card.detail)
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            VStack(alignment: .trailing, spacing: 7) {
                Text(card.amount)
                    .font(BONTypography.geistPixel(size: 16))
                    .foregroundStyle(BONColor.textPrimary)
                    .lineLimit(1)

                Text(card.minPayment)
                    .font(BONTypography.zalando(size: 14, weight: .light))
                    .foregroundStyle(Color(red: 0.78, green: 0.51, blue: 0.0))
                    .lineLimit(1)
            }
        }
        .frame(height: 72)
        .padding(.horizontal, 16)
    }
}

private struct FirstTimerInsightBlock: View {
    let width: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("Chase freedom credit card costing you")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)

            Text("$5250/yr")
                .font(BONTypography.geistPixel(size: 32))
                .tracking(-0.64)
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 42)

            Text("That's $14 every single day, gone. Let’s tackle\nthis card right away.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineSpacing(5)
        }
        .frame(width: width, alignment: .leading)
    }
}

private struct FirstTimerSuggestionBubble: View {
    let title: String
    let width: CGFloat

    init(_ title: String, width: CGFloat) {
        self.title = title
        self.width = width
    }

    var body: some View {
        Button {
            BONHaptics.selection()
        } label: {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .tracking(-0.14)
                .lineLimit(1)
                .minimumScaleFactor(0.92)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(width: width, alignment: .leading)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 20,
                            bottomLeading: 20,
                            bottomTrailing: 0,
                            topTrailing: 20
                        ),
                        style: .continuous
                    )
                    .fill(BONColor.accentLime)
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

private struct FirstTimerChatComposer: View {
    let width: CGFloat
    let placeholder: String
    let action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            HStack(spacing: 0) {
                Text(placeholder)
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textOnDark.opacity(0.58))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 24)

                ZStack {
                    BONChatComposerActionSurface()

                    Image("chatVoice")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(BONColor.textOnDark)
                        .frame(width: 16, height: 16)
                }
                .frame(width: 72, height: 52)
                .padding(.trailing, 6)
            }
            .frame(width: width, height: 64)
            .background(BONChatGlassCapsule())
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(placeholder)
    }
}

// MARK: - Home Dashboard

private struct FirstTimerHomeDashboardView: View {
    let metrics: HomeFirstTimerMetrics
    let namespace: Namespace.ID
    @Binding var scrollPosition: ScrollPosition
    @Binding var scrollOffset: CGFloat
    @Binding var didApplyInitialOffset: Bool
    let initialOffset: CGFloat
    let onBudgeting: () -> Void
    let onShowAIReport: () -> Void
    let onOpenCredit: () -> Void

    var body: some View {
        let collapseProgress = min(1, max(0, (scrollOffset - 80) / 140))
        let navHeight = 64 - (20 * collapseProgress)
        let navBottom = metrics.expandedNavBottom + ((metrics.compactNavBottom - metrics.expandedNavBottom) * collapseProgress)
        let topAIModeOpacity = 1 - firstTimerSmoothStep(min(1, max(0, scrollOffset / 120)))
        let talkMoveProgress = firstTimerSmoothStep(min(1, max(0, scrollOffset / 220)))
        let talkSourceY = 386.5 - scrollOffset
        let talkTargetY = metrics.topControlCenterY
        let talkCenterY = talkSourceY + ((talkTargetY - talkSourceY) * talkMoveProgress)

        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    FirstTimerDashboardPreview(
                        metrics: metrics,
                        namespace: namespace,
                        scrollOffset: scrollOffset
                    )
                        .frame(width: metrics.screenWidth, height: 443)
                        .clipped()

                    FirstTimerDashboardContent(
                        metrics: metrics,
                        onBudgeting: onBudgeting,
                        onCredit: onOpenCredit
                    )
                    .padding(.top, 32)

                    Color.clear
                        .frame(height: 260 + metrics.safeBottom)
                }
                .frame(width: metrics.screenWidth)
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 0, for: .scrollContent)
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y)
            } action: { _, newValue in
                scrollOffset = newValue
            }
            .task(id: metrics.screenHeight) {
                guard !didApplyInitialOffset, initialOffset > 0 else {
                    return
                }

                didApplyInitialOffset = true
                scrollOffset = initialOffset
                scrollPosition.scrollTo(y: initialOffset)
            }

            FirstTimerTopChrome(
                metrics: metrics,
                center: .aiMode,
                left: .profile,
                right: .bell,
                namespace: namespace,
                collapseProgress: collapseProgress,
                centerOpacity: topAIModeOpacity,
                onCenter: onShowAIReport,
                onLeft: {},
                onRight: {}
            )

            FirstTimerCenterPill(kind: .talkAI) {
                onShowAIReport()
            }
                .matchedGeometryEffect(id: "home-floating-talk-ai", in: namespace)
                .scaleEffect(1 - (talkMoveProgress * 0.035))
                .position(x: metrics.screenWidth / 2, y: talkCenterY)
                .zIndex(3)

            BONBottomNav(
                selectedID: "home",
                items: HomeFirstTimerFixture.navItems,
                width: metrics.contentWidth,
                variant: collapseProgress >= 1 ? .compact : .expanded,
                collapseProgress: collapseProgress
            ) { item in
                if item.id == "credit" {
                    onOpenCredit()
                }
            }
            .position(
                x: metrics.screenWidth / 2,
                y: metrics.screenHeight - navBottom - (navHeight / 2)
            )
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
    }
}

private struct FirstTimerDashboardPreview: View {
    let metrics: HomeFirstTimerMetrics
    let namespace: Namespace.ID
    let scrollOffset: CGFloat

    var body: some View {
        let panelWidth = metrics.screenWidth - 16
        let panelHeight: CGFloat = 435
        let reportWidth = metrics.contentWidth
        let fadeProgress = firstTimerSmoothStep(min(1, max(0, scrollOffset / 190)))
        let panelOpacity = max(0, 1 - fadeProgress)
        let panelScale = 1 - (fadeProgress * 0.035)
        let panelYOffset = -(fadeProgress * 18)

        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 56, style: .continuous)
                    .fill(Color.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 56, style: .continuous)
                            .stroke(BONColor.lime100.opacity(0.56), lineWidth: 6)
                            .blur(radius: 8)
                            .padding(-1)
                    }
                    .shadow(color: BONColor.lime100.opacity(0.28), radius: 18, x: 0, y: 0)

                Text("Hi Marcus, I reviewed your credit\nreport here’s what I found")
                    .font(BONTypography.zalando(size: 16, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(width: 253, height: 44)
                    .position(x: panelWidth / 2, y: 160)

                HStack(spacing: 12) {
                    FirstTimerCreditScoreCard(width: (reportWidth - 12) / 2)
                    FirstTimerLiabilitiesCard(width: (reportWidth - 12) / 2)
                }
                .frame(width: reportWidth)
                .position(x: panelWidth / 2, y: 280)

                FirstTimerOpenCardsPanel(width: reportWidth)
                    .position(x: panelWidth / 2, y: 370 + 197)
            }
            .frame(width: panelWidth, height: panelHeight)
            .matchedGeometryEffect(id: "first-timer-ai-report-surface", in: namespace)
            .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))
            .opacity(panelOpacity)
            .scaleEffect(panelScale, anchor: .top)
            .blur(radius: fadeProgress * 1.2)
            .offset(y: panelYOffset)
            .position(x: metrics.screenWidth / 2, y: 8 + (panelHeight / 2))
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: FirstTimerAIReportFrameKey.self,
                        value: proxy.frame(in: .named("firstTimerHomeRoot"))
                    )
                }
            }
        }
    }
}

private struct FirstTimerDashboardContent: View {
    let metrics: HomeFirstTimerMetrics
    let onBudgeting: () -> Void
    let onCredit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("More actions")
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: metrics.contentWidth, alignment: .leading)

            HStack(alignment: .top) {
                FirstTimerActionShortcut(icon: .asset("homeActionActiveCards"), title: "Active cards")
                Spacer(minLength: 0)
                FirstTimerActionShortcut(icon: .asset("homeActionGetCash"), title: "Get Cash")
                Spacer(minLength: 0)
                FirstTimerActionShortcut(icon: .asset("homeActionReferEarn"), title: "Refer & earn")
            }
            .frame(width: metrics.contentWidth)
            .padding(.top, 20)

            HStack(alignment: .top, spacing: 0) {
                FirstTimerActionShortcut(icon: .asset("homeActionCreditScore"), title: "Credit score", action: onCredit)
                    .frame(width: 79)

                Spacer(minLength: 0)

                FirstTimerBudgetingCard(
                    width: metrics.contentWidth - 121,
                    action: onBudgeting
                )
                    .padding(.top, 0)
            }
            .padding(.top, 21)

            FirstTimerDashedDivider()
                .frame(height: 1)
                .padding(.top, 28)

            FirstTimerSecurityCard(width: metrics.contentWidth)
                .padding(.top, 49)
        }
        .frame(width: metrics.contentWidth, alignment: .leading)
    }
}

private enum DashboardIcon {
    case asset(String)
}

private struct FirstTimerActionShortcut: View {
    let icon: DashboardIcon
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            BONHaptics.selection()
            action()
        } label: {
            VStack(spacing: 12) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.97, green: 0.97, blue: 0.97)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(Circle().stroke(BONColor.borderSubtle, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 8)
                    .frame(width: 64, height: 64)
                    .overlay {
                        iconView
                    }

                Text(title)
                    .font(BONTypography.zalando(size: 14, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }
            .frame(width: 80)
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .asset(let name):
            Image(name)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color.black)
                .frame(width: 20, height: 20)
        }
    }
}

private struct FirstTimerBudgetingCard: View {
    let width: CGFloat
    let action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            ZStack(alignment: .topLeading) {
                Image("homeActionBudgetingArtwork")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(width: 192, height: 87)
                    .clipped()
                    .position(x: -100 + 96, y: 8 + 43.5)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.97, green: 0.97, blue: 0.97)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 16, height: 105)
                    .blur(radius: 4)
                    .position(x: 86 + 8, y: 45)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Do free budgeting")
                        .font(BONTypography.zalando(size: 12, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.94)

                    Text("Start now")
                        .font(BONTypography.zalando(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 77, height: 25)
                        .background(Capsule(style: .continuous).fill(Color.black))
                }
                .frame(width: 112, height: 47, alignment: .leading)
                .position(x: 102 + 56, y: 21 + 23.5)
            }
            .frame(width: width, height: 90)
            .clipped()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color(red: 0.98, green: 0.98, blue: 0.98)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(BONColor.borderSubtle, lineWidth: 1)
                    )
            )
            .background {
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: FirstTimerBudgetingCardFrameKey.self,
                        value: proxy.frame(in: .named("firstTimerHomeRoot"))
                    )
                }
            }
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel("Do free budgeting. Start now.")
    }
}

private struct FirstTimerAIReportMorphOverlay: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let metrics: HomeFirstTimerMetrics
    let sourceFrame: CGRect
    let progress: CGFloat
    let isClosing: Bool

    private var easedProgress: CGFloat {
        firstTimerSmoothStep(progress)
    }

    private var source: CGRect {
        guard sourceFrame.width > 0, sourceFrame.height > 0 else {
            return fallbackSource
        }

        return sourceFrame
    }

    private var fallbackSource: CGRect {
        CGRect(
            x: 8,
            y: 8,
            width: metrics.screenWidth - 16,
            height: 435
        )
    }

    private var surfaceRect: CGRect {
        let p = easedProgress
        return CGRect(
            x: firstTimerLerp(source.minX, 0, p),
            y: firstTimerLerp(source.minY, 0, p),
            width: firstTimerLerp(source.width, metrics.screenWidth, p),
            height: firstTimerLerp(source.height, metrics.screenHeight, p)
        )
    }

    var body: some View {
        let p = easedProgress
        let rect = surfaceRect
        let surfaceOpacity = firstTimerRangeProgress(p, start: 0.02, end: 0.20)
        let backgroundWash = firstTimerRangeProgress(p, start: 0.08, end: 0.34) * 0.94
        let contentProgress = isClosing
            ? firstTimerRangeProgress(p, start: 0.12, end: 0.46)
            : firstTimerRangeProgress(p, start: 0.28, end: 0.64)
        let chromeProgress = isClosing
            ? firstTimerRangeProgress(p, start: 0.20, end: 0.54)
            : firstTimerRangeProgress(p, start: 0.38, end: 0.72)
        let glowProgress = reduceTransparency ? 0 : firstTimerRangeProgress(p, start: 0.06, end: 0.44)

        ZStack(alignment: .topLeading) {
            Color.white
                .opacity(backgroundWash)
                .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(Color.white.opacity(surfaceOpacity))
                .overlay {
                    RoundedRectangle(cornerRadius: 56, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    BONColor.lime50.opacity(0.44 * glowProgress),
                                    BONColor.lime100.opacity(0.74 * glowProgress),
                                    BONColor.lime200.opacity(0.70 * glowProgress),
                                    BONColor.lime300.opacity(0.42 * glowProgress)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 7
                        )
                        .blur(radius: 10)
                        .padding(-2)
                }
                .shadow(color: BONColor.lime100.opacity(0.18 * glowProgress), radius: 22, x: 0, y: 0)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)

            FirstTimerAIReportMorphContent(
                metrics: metrics,
                contentProgress: contentProgress,
                chromeProgress: chromeProgress
            )
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
            .opacity(contentProgress)
            .scaleEffect(firstTimerLerp(0.985, 1, p), anchor: .top)
            .mask {
                RoundedRectangle(cornerRadius: 56, style: .continuous)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        .clipShape(Rectangle())
    }
}

private struct FirstTimerAIReportMorphContent: View {
    let metrics: HomeFirstTimerMetrics
    let contentProgress: CGFloat
    let chromeProgress: CGFloat

    var body: some View {
        let reportWidth = metrics.reportContentWidth

        ZStack(alignment: .top) {
            Color.white

            VStack(spacing: 0) {
                Color.clear
                    .frame(height: metrics.safeTop + 109)

                Text("Hi Marcus, I reviewed your credit\nreport here’s what I found")
                    .font(BONTypography.zalando(size: 16, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .frame(width: reportWidth, height: 44)
                    .opacity(contentProgress)
                    .offset(y: (1 - contentProgress) * 5)

                HStack(spacing: 12) {
                    FirstTimerCreditScoreCard(width: (reportWidth - 12) / 2)
                    FirstTimerLiabilitiesCard(width: (reportWidth - 12) / 2)
                }
                .frame(width: reportWidth)
                .opacity(contentProgress)
                .offset(y: (1 - contentProgress) * 7)
                .padding(.top, 22)

                FirstTimerOpenCardsPanel(width: reportWidth)
                    .opacity(contentProgress)
                    .offset(y: (1 - contentProgress) * 9)
                    .padding(.top, 12)

                Spacer(minLength: 0)
            }
            .frame(width: metrics.screenWidth)

            AIChatTopScrim()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .ignoresSafeArea(.container, edges: .top)
                .allowsHitTesting(false)
                .opacity(chromeProgress)

            ZStack {
                FirstTimerTopIcon(side: .menu, action: {})
                    .position(x: metrics.horizontalMargin + 20, y: metrics.topControlCenterY)

                FirstTimerCenterPill(kind: .linkCards, action: {})
                    .position(x: metrics.screenWidth / 2, y: metrics.topControlCenterY)

                FirstTimerTopIcon(side: .home, action: {})
                    .position(x: metrics.screenWidth - metrics.horizontalMargin - 20, y: metrics.topControlCenterY)
            }
            .frame(width: metrics.screenWidth, height: metrics.safeTop + 82)
            .opacity(chromeProgress)
            .offset(y: -(1 - chromeProgress) * 4)
        }
    }
}

private struct FirstTimerBudgetingTransitionOverlay: View {
    let metrics: HomeFirstTimerMetrics
    let sourceFrame: CGRect
    let progress: CGFloat

    private var easedProgress: CGFloat {
        firstTimerSmoothStep(progress)
    }

    private var source: CGRect {
        if sourceFrame.width > 0, sourceFrame.height > 0 {
            return sourceFrame
        }

        let width = metrics.contentWidth - 121
        return CGRect(
            x: metrics.horizontalMargin + metrics.contentWidth - width,
            y: 630,
            width: width,
            height: 90
        )
    }

    private var surfaceRect: CGRect {
        let p = easedProgress
        return CGRect(
            x: firstTimerLerp(source.minX, 0, p),
            y: firstTimerLerp(source.minY, 0, p),
            width: firstTimerLerp(source.width, metrics.screenWidth, p),
            height: firstTimerLerp(source.height, metrics.screenHeight, p)
        )
    }

    var body: some View {
        let p = easedProgress
        let rect = surfaceRect
        let cornerRadius = firstTimerLerp(20, 56, p)
        let cardContentProgress = 1 - firstTimerRangeProgress(p, start: 0.10, end: 0.42)
        let titleProgress = firstTimerRangeProgress(p, start: 0.12, end: 0.30)
        let heatmapResolveProgress = firstTimerRangeProgress(p, start: 0.18, end: 0.72)
        let heatmapOpacity = firstTimerRangeProgress(p, start: 0.14, end: 0.36)
        let rowsProgress = firstTimerRangeProgress(p, start: 0.38, end: 0.86)
        let fadeProgress = firstTimerRangeProgress(p, start: 0.54, end: 0.78)
        let ctaProgress = firstTimerRangeProgress(p, start: 0.70, end: 0.94)
        let closeProgress = firstTimerRangeProgress(p, start: 0.62, end: 0.84)
        let miniArtworkProgress = firstTimerRangeProgress(p, start: 0.00, end: 0.52)

        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(BONColor.backgroundPrimary)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(BONColor.borderSubtle.opacity(1 - p), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.06 * (1 - p)), radius: 16, x: 0, y: 8)
                .frame(width: rect.width, height: rect.height)
                .position(x: rect.midX, y: rect.midY)

            ZStack(alignment: .topLeading) {
                cardTextOverlay(opacity: cardContentProgress)

                Image("homeActionBudgetingArtwork")
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
                    .frame(
                        width: firstTimerLerp(192, metrics.compactColumn, miniArtworkProgress),
                        height: firstTimerLerp(87, 156, miniArtworkProgress)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: firstTimerLerp(0, 6, miniArtworkProgress), style: .continuous))
                    .opacity(1 - firstTimerRangeProgress(p, start: 0.46, end: 0.72))
                    .position(
                        x: firstTimerLerp(source.minX - 4, metrics.centerX(195), miniArtworkProgress),
                        y: firstTimerLerp(source.minY + 51.5, 317, miniArtworkProgress)
                    )

                fullScreenContent(
                    titleProgress: titleProgress,
                    heatmapResolveProgress: heatmapResolveProgress,
                    heatmapOpacity: heatmapOpacity,
                    rowsProgress: rowsProgress,
                    fadeProgress: fadeProgress,
                    ctaProgress: ctaProgress,
                    closeProgress: closeProgress
                )
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
            .mask {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        .clipShape(Rectangle())
    }

    private func cardTextOverlay(opacity: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Do free budgeting")
                .font(BONTypography.zalando(size: 12, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.94)

            Text("Start now")
                .font(BONTypography.zalando(size: 12, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 77, height: 25)
                .background(Capsule(style: .continuous).fill(Color.black))
        }
        .frame(width: 112, height: 47, alignment: .leading)
        .opacity(opacity)
        .position(x: source.minX + 158, y: source.minY + 44.5)
    }

    private func fullScreenContent(
        titleProgress: CGFloat,
        heatmapResolveProgress: CGFloat,
        heatmapOpacity: CGFloat,
        rowsProgress: CGFloat,
        fadeProgress: CGFloat,
        ctaProgress: CGFloat,
        closeProgress: CGFloat
    ) -> some View {
        ZStack(alignment: .top) {
            Text("Free Smart Budgeting")
                .font(BONTypography.zalando(size: 24, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: metrics.compactColumn, height: 29)
                .opacity(titleProgress)
                .offset(y: (1 - titleProgress) * 6)
                .position(x: metrics.centerX(194.5), y: 176.5)

            FirstTimerBudgetHeatmap(resolveProgress: heatmapResolveProgress)
                .frame(width: metrics.compactColumn, height: 156)
                .opacity(heatmapOpacity)
                .position(x: metrics.centerX(195), y: 317)

            FirstTimerBudgetRows(
                width: metrics.compactColumn,
                revealProgress: rowsProgress,
                diningEmphasis: 0
            )
            .position(x: metrics.centerX(195), y: 539)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.92),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: metrics.screenWidth, height: 104)
                .opacity(fadeProgress)
                .position(x: metrics.screenWidth / 2, y: 649)
                .allowsHitTesting(false)

            FirstTimerPlanButton(revealProgress: ctaProgress) {}
                .frame(width: metrics.compactColumn, height: 48)
                .opacity(ctaProgress)
                .offset(y: (1 - ctaProgress) * 6)
                .position(x: metrics.centerX(195), y: 773)

            FirstTimerBudgetCloseButton(action: {})
                .opacity(closeProgress)
                .offset(y: -(1 - closeProgress) * 4)
                .position(x: metrics.centerX(346), y: metrics.topControlCenterY)
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
    }
}

private struct FirstTimerSecurityCard: View {
    let width: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)

            HStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.68, green: 0.72, blue: 0.72),
                            Color(red: 0.93, green: 0.94, blue: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.white.opacity(0.46))
                }
                .frame(width: 112, height: 112)

                VStack(alignment: .leading, spacing: 12) {
                    Text("100% secure and\nprivate")
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                        .lineSpacing(1)
                        .frame(width: 158, height: 38, alignment: .leading)

                    Text("We never sell or share\nyour data.")
                        .font(BONTypography.zalando(size: 14, weight: .regular))
                        .foregroundStyle(BONColor.textPrimary)
                        .lineSpacing(0)
                        .frame(width: 158, height: 28, alignment: .leading)
                }
                .padding(.leading, 32)

                Spacer(minLength: 0)
            }
            .frame(width: width - 16, height: 112)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.56),
                        Color(red: 0.93, green: 0.93, blue: 0.93)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .overlay(Rectangle().stroke(BONColor.borderSubtle, lineWidth: 1))
            )
        }
        .frame(width: width, height: 128)
    }
}

// MARK: - Budgeting

private struct FirstTimerBudgetingView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var diningEmphasis: CGFloat = 0

    let metrics: HomeFirstTimerMetrics
    let onClose: () -> Void

    var body: some View {
        let effectiveStage: CGFloat = 1
        let titleProgress = firstTimerRangeProgress(effectiveStage, start: 0.16, end: 0.40)
        let heatmapProgress = firstTimerRangeProgress(effectiveStage, start: 0.18, end: 0.70)
        let rowsProgress = firstTimerRangeProgress(effectiveStage, start: 0.66, end: 0.98)
        let ctaProgress = firstTimerRangeProgress(effectiveStage, start: 0.88, end: 1.0)
        let closeProgress = firstTimerRangeProgress(effectiveStage, start: 0.02, end: 0.26)

        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(BONColor.backgroundPrimary)
                .frame(width: metrics.screenWidth, height: metrics.screenHeight)
                .ignoresSafeArea()

            Text("Free Smart Budgeting")
                .font(BONTypography.zalando(size: 24, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: metrics.compactColumn, height: 29)
                .opacity(titleProgress)
                .offset(y: (1 - titleProgress) * 6)
                .position(x: metrics.centerX(194.5), y: 176.5)

            FirstTimerBudgetHeatmap(resolveProgress: heatmapProgress)
                .frame(width: metrics.compactColumn, height: 156)
                .opacity(firstTimerRangeProgress(effectiveStage, start: 0.04, end: 0.28))
                .position(x: metrics.centerX(195), y: 317)

            FirstTimerBudgetRows(
                width: metrics.compactColumn,
                revealProgress: rowsProgress,
                diningEmphasis: diningEmphasis
            )
            .position(x: metrics.centerX(195), y: 539)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.92),
                            Color.white
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: metrics.screenWidth, height: 104)
                .opacity(firstTimerRangeProgress(effectiveStage, start: 0.58, end: 0.84))
                .position(x: metrics.screenWidth / 2, y: 649)
                .allowsHitTesting(false)

            FirstTimerPlanButton(revealProgress: ctaProgress) {}
                .frame(width: metrics.compactColumn, height: 48)
                .opacity(ctaProgress)
                .offset(y: (1 - ctaProgress) * 6)
                .position(x: metrics.centerX(195), y: 773)

            FirstTimerBudgetCloseButton(action: close)
                .opacity(closeProgress)
                .offset(y: -(1 - closeProgress) * 4)
                .position(x: metrics.centerX(346), y: metrics.topControlCenterY)
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        .onAppear(perform: beginOpenAnimation)
    }

    private func beginOpenAnimation() {
        if reduceMotion {
            return
        }

        diningEmphasis = 0

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 260_000_000)
            withAnimation(.easeOut(duration: 0.18)) {
                diningEmphasis = 1
            }
            try? await Task.sleep(nanoseconds: 190_000_000)
            withAnimation(.easeOut(duration: 0.18)) {
                diningEmphasis = 0
            }
        }
    }

    private func close() {
        if reduceMotion {
            onClose()
            return
        }

        withAnimation(.easeOut(duration: 0.16)) {
            diningEmphasis = 0
        }

        onClose()
    }
}

private struct FirstTimerBudgetHeatmap: View {
    let resolveProgress: CGFloat

    private static let rows = [
        ".........x....................",
        ".........x.x...x...x.........x",
        "...x..x..xxxx..x...xx.......xx",
        "...xx.x..xxxx..xxx.xx..x....xx",
        "x..xx.x..xxxx.xxxx.xx.xx....xx",
        "x..xx.x.xxxxx.xxxx.xx.xx....xx",
        "x..xx.x.xxxxxxxxxxxxx.xx....xx",
        "x..xx.x.xxxxxxxxxxxxx.xxx...xx",
        "x..xx.x.xxxxxxxxxxxxxxxxx...xx",
        "x..xx.xxxxxxxxxxxxxxxxxxxx.xxx",
        "x..xx.xxxxxxxxxxxxxxxxxxxx.xxx",
        "xx.xxxxxxxxxxxxxxxxxxxxxxx.xxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxx.xxx",
        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    ]

    private static let rowColors: [FirstTimerRGB] = [
        .hex(0xFF3333),
        .hex(0xFF5C5C),
        .hex(0xFFBBBB),
        .hex(0xFFE1E1),
        .hex(0xFFEEEE),
        .hex(0xFFEFE5),
        .hex(0xFFF7EA),
        .hex(0xF9F6D0),
        .hex(0xFFFBD9),
        .hex(0xECFFAA),
        .hex(0xDBFF6F),
        .hex(0xC5FF33),
        .hex(0xB4FF33),
        .hex(0xA1FF00)
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                ForEach(Self.rows.indices, id: \.self) { row in
                    let cells = Array(Self.rows[row])

                    ForEach(cells.indices, id: \.self) { column in
                        if cells[column] == "x" {
                            let localResolve = columnResolveProgress(column)

                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(resolvedColor(row: row, progress: localResolve))
                                .frame(width: 8, height: 8)
                                .scaleEffect(0.88 + (localResolve * 0.12))
                                .opacity(0.42 + (localResolve * 0.58))
                                .offset(x: 5 + (CGFloat(column) * 10), y: CGFloat(row) * 10)
                        }
                    }
                }
            }
            .frame(width: 310, height: 140, alignment: .topLeading)

            HStack {
                Text("Apr 05")
                Spacer()
                Text("Apr 20")
                Spacer()
                Text("May 05")
            }
            .font(BONTypography.zalando(size: 10, weight: .regular))
            .foregroundStyle(Color.black.opacity(0.48))
            .frame(height: 14)
            .position(x: 155, y: 150)
        }
        .frame(width: 310, height: 156, alignment: .topLeading)
    }

    private func columnResolveProgress(_ column: Int) -> CGFloat {
        let groupDelay = CGFloat(column / 5) * 0.075
        return firstTimerRangeProgress(resolveProgress, start: groupDelay, end: min(1, groupDelay + 0.46))
    }

    private func resolvedColor(row: Int, progress: CGFloat) -> Color {
        let neutral = FirstTimerRGB.hex(0xF1F3EA)
        let resolved = Self.rowColors[row]
        return neutral.mixed(with: resolved, progress: progress).color
    }
}

private struct FirstTimerRGB {
    let red: Double
    let green: Double
    let blue: Double

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }

    static func hex(_ value: Int) -> FirstTimerRGB {
        FirstTimerRGB(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0
        )
    }

    func mixed(with other: FirstTimerRGB, progress: CGFloat) -> FirstTimerRGB {
        let t = Double(min(1, max(0, progress)))
        return FirstTimerRGB(
            red: red + ((other.red - red) * t),
            green: green + ((other.green - green) * t),
            blue: blue + ((other.blue - blue) * t)
        )
    }
}

private struct FirstTimerBudgetRows: View {
    let width: CGFloat
    let revealProgress: CGFloat
    let diningEmphasis: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            BudgetCategoryRow(
                iconAsset: "budgetDining",
                title: "Dining",
                amount: "$353",
                trend: .up("$112"),
                revealProgress: rowProgress(0),
                amountProgress: amountProgress(0),
                trendProgress: trendProgress(0),
                emphasis: diningEmphasis
            )
            .position(x: width / 2, y: 12)

            divider(y: 40)

            BudgetCategoryRow(
                iconAsset: "budgetUtilities",
                title: "Utilities",
                amount: "$120",
                trend: .flat,
                revealProgress: rowProgress(1),
                amountProgress: amountProgress(1),
                trendProgress: trendProgress(1),
                emphasis: 0
            )
            .position(x: width / 2, y: 68)

            divider(y: 96)

            BudgetCategoryRow(
                iconAsset: "budgetEntertainment",
                title: "Entertainment",
                amount: "$90",
                trend: .down("$28"),
                revealProgress: rowProgress(2),
                amountProgress: amountProgress(2),
                trendProgress: trendProgress(2),
                emphasis: 0
            )
            .position(x: width / 2, y: 124)

            divider(y: 152)

            BudgetCategoryRow(
                iconAsset: "budgetOther",
                title: "Others",
                amount: "$45",
                trend: .down("$05"),
                revealProgress: rowProgress(3),
                amountProgress: amountProgress(3),
                trendProgress: trendProgress(3),
                emphasis: 0
            )
            .opacity(0.18 * rowProgress(3))
            .position(x: width / 2, y: 180)

            divider(y: 208)
        }
        .frame(width: width, height: 208)
    }

    private func divider(y: CGFloat) -> some View {
        Rectangle()
            .fill(BONColor.divider)
            .frame(width: width, height: 1 / UIScreen.main.scale)
            .position(x: width / 2, y: y)
    }

    private func rowProgress(_ index: Int) -> CGFloat {
        let start = CGFloat(index) * 0.13
        return firstTimerRangeProgress(revealProgress, start: start, end: start + 0.34)
    }

    private func amountProgress(_ index: Int) -> CGFloat {
        let start = 0.10 + CGFloat(index) * 0.13
        return firstTimerRangeProgress(revealProgress, start: start, end: start + 0.30)
    }

    private func trendProgress(_ index: Int) -> CGFloat {
        let start = 0.20 + CGFloat(index) * 0.13
        return firstTimerRangeProgress(revealProgress, start: start, end: start + 0.28)
    }
}

private enum BudgetTrend {
    case up(String)
    case down(String)
    case flat

    var text: String {
        switch self {
        case .up(let text), .down(let text):
            return text
        case .flat:
            return "—"
        }
    }

    var icon: String? {
        switch self {
        case .up:
            return "arrow.up"
        case .down:
            return "arrow.down"
        case .flat:
            return nil
        }
    }

    var iconColor: Color {
        switch self {
        case .up:
            return Color(red: 1.0, green: 0.20, blue: 0.20)
        case .down:
            return BONColor.lime600
        case .flat:
            return BONColor.textTertiary
        }
    }
}

private struct BudgetCategoryRow: View {
    let iconAsset: String
    let title: String
    let amount: String
    let trend: BudgetTrend
    let revealProgress: CGFloat
    let amountProgress: CGFloat
    let trendProgress: CGFloat
    let emphasis: CGFloat

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                Image(iconAsset)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .tracking(0.32)
                    .foregroundStyle(BONColor.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .scaleEffect(1 + (emphasis * 0.012), anchor: .leading)
            }
            .opacity(revealProgress)
            .offset(y: (1 - revealProgress) * 8)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Text(amount)
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .tracking(0.32)
                    .foregroundStyle(BONColor.textPrimary)
                    .lineLimit(1)
                    .opacity(amountProgress)
                    .offset(y: (1 - amountProgress) * 6)

                trendView
                    .opacity(trendProgress)
                    .offset(y: (1 - trendProgress) * 5)
            }
        }
        .frame(width: 310, height: 24)
    }

    @ViewBuilder
    private var trendView: some View {
        if let icon = trend.icon {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(trend.iconColor)

                Text(trend.text)
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .tracking(-0.12)
                    .foregroundStyle(Color(red: 0.47, green: 0.47, blue: 0.47))
                    .lineLimit(1)
            }
        } else {
            Text(trend.text)
                .font(BONTypography.zalando(size: 12, weight: .light))
                .tracking(-0.12)
                .foregroundStyle(Color(red: 0.47, green: 0.47, blue: 0.47))
                .frame(width: 11, alignment: .center)
        }
    }
}

private struct FirstTimerPlanButton: View {
    let revealProgress: CGFloat
    let action: () -> Void

    var body: some View {
        BONIntentCTA(
            title: "Build your plan",
            revealProgress: revealProgress,
            action: action
        )
    }
}

private struct FirstTimerBudgetCloseButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            Circle()
                .fill(Color.white.opacity(0.24))
                .overlay(Circle().stroke(Color.black.opacity(0.04), lineWidth: 1))
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                .frame(width: 40, height: 40)
                .overlay {
                    Image("budgetClose")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel("Close")
    }
}

private struct FirstTimerPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .semibold))
                .foregroundStyle(BONColor.textPrimary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(BONColor.accentLime)
                        .overlay(Capsule(style: .continuous).stroke(Color.black, lineWidth: 1.2))
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Shared Chrome

private enum FirstTimerTopCenter {
    case linkCards
    case aiMode
    case talkAI
}

private enum FirstTimerTopSide {
    case menu
    case profile
    case bell
    case home
}

private struct FirstTimerTopChrome: View {
    let metrics: HomeFirstTimerMetrics
    let center: FirstTimerTopCenter
    let left: FirstTimerTopSide
    let right: FirstTimerTopSide
    let namespace: Namespace.ID
    var aiEntryNamespace: Namespace.ID?
    var aiEntrySourceID: String?
    var isActiveAITransitionSource = false
    var collapseProgress: CGFloat = 0
    var centerOpacity: CGFloat = 1
    let onCenter: () -> Void
    let onLeft: () -> Void
    let onRight: () -> Void

    var body: some View {
        ZStack {
            FirstTimerTopIcon(side: left, action: onLeft)
                .position(x: metrics.horizontalMargin + 20, y: metrics.topControlCenterY)

            centerPill
                .matchedGeometryEffect(id: "top-center-pill", in: namespace)
                .modifier(
                    HomeAIEntrySourceModifier(
                        namespace: aiEntryNamespace,
                        sourceID: aiEntrySourceID,
                        isActive: isActiveAITransitionSource
                    )
                )
                .opacity(centerOpacity)
                .scaleEffect(1 - (collapseProgress * 0.03))
                .position(x: metrics.screenWidth / 2, y: metrics.topControlCenterY)

            FirstTimerTopIcon(side: right, action: onRight)
                .matchedGeometryEffect(id: right == .home ? "home-top-icon" : "right-top-icon", in: namespace)
                .position(x: metrics.screenWidth - metrics.horizontalMargin - 20, y: metrics.topControlCenterY)
        }
        .frame(width: metrics.screenWidth, height: metrics.safeTop + 82)
    }

    @ViewBuilder
    private var centerPill: some View {
        FirstTimerCenterPill(kind: center, action: onCenter)
    }
}

private struct FirstTimerCenterPill: View {
    let kind: FirstTimerTopCenter
    let action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            switch kind {
            case .linkCards:
                Text("Link credit cards")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 132, height: 40)
                    .background(FirstTimerDarkGlassCapsule())
            case .aiMode:
                Text("AI mode")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .frame(width: 110, height: 40)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.72))
                            .overlay(Capsule(style: .continuous).stroke(BONColor.borderSubtle.opacity(0.58), lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 7)
                    )
            case .talkAI:
                Text("Talk with AI")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(.white)
                    .frame(width: 112, height: 33)
                    .background(FirstTimerDarkGlassCapsule())
            }
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        switch kind {
        case .linkCards:
            return "Link credit cards"
        case .aiMode:
            return "AI mode"
        case .talkAI:
            return "Talk with AI"
        }
    }
}

private struct FirstTimerDarkGlassCapsule: View {
    var body: some View {
        BONChatExpertPillSurface()
    }
}

private struct FirstTimerTopIcon: View {
    let side: FirstTimerTopSide
    let action: () -> Void

    var body: some View {
        FirstTimerGlassIconButton(
            image: iconImage,
            symbol: iconSymbol,
            accessibilityLabel: accessibilityLabel,
            action: action
        )
    }

    private var iconImage: String? {
        switch side {
        case .menu:
            return "chatMenu"
        case .profile:
            return "topProfile"
        case .bell:
            return "topBell"
        case .home:
            return "navHome"
        }
    }

    private var iconSymbol: String? {
        switch side {
        case .menu, .profile, .bell, .home:
            return nil
        }
    }

    private var accessibilityLabel: String {
        switch side {
        case .menu:
            return "Menu"
        case .profile:
            return "Profile"
        case .bell:
            return "Notifications"
        case .home:
            return "Home"
        }
    }
}

private struct FirstTimerGlassIconButton: View {
    var image: String?
    var symbol: String?
    let accessibilityLabel: String
    let action: () -> Void

    init(
        image: String? = nil,
        symbol: String? = nil,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.symbol = symbol
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            if let image {
                BONChatTopIconControl(imageAsset: image, iconSize: 16)
            } else if let symbol {
                BONChatTopIconControl(systemName: symbol, iconSize: 16)
            }
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct FirstTimerDashedDivider: View {
    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
            }
            .stroke(
                BONColor.divider,
                style: StrokeStyle(lineWidth: 1, dash: [3, 4])
            )
        }
    }
}

private struct HomeAIEntrySourceModifier: ViewModifier {
    let namespace: Namespace.ID?
    let sourceID: String?
    let isActive: Bool

    func body(content: Content) -> some View {
        if let namespace, let sourceID, isActive {
            content.matchedTransitionSource(id: sourceID, in: namespace)
        } else {
            content
        }
    }
}

#Preview {
    HomeFirstTimerClickedView()
}
