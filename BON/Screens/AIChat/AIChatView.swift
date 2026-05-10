import SwiftUI
import UIKit

struct AIChatView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss
    @FocusState private var composerFocused: Bool

    @State private var draft: String
    @State private var sentPrompt: String?
    @State private var phase: AIChatPhase
    @State private var scenario: AIChatScenario?
    @State private var didAppear = false
    @State private var didApplyLaunchScroll = false
    @State private var responseTask: Task<Void, Never>?

    private let entryNamespace: Namespace.ID?
    private let sourceID: String
    private let launchScrollTarget: AIChatLaunchScrollTarget?
    private let bottomAnchorID = "chat-bottom-anchor"

    init(
        entryNamespace: Namespace.ID? = nil,
        sourceID: String = AIChatEntrySource.cta.transitionID,
        usesLaunchArguments: Bool = false
    ) {
        let launchState = usesLaunchArguments ? AIChatLaunchState.fromLaunchArguments() : .initial
        self.entryNamespace = entryNamespace
        self.sourceID = sourceID
        self.launchScrollTarget = launchState.scrollTarget
        _draft = State(initialValue: launchState.draft)
        _sentPrompt = State(initialValue: launchState.sentPrompt)
        _phase = State(initialValue: launchState.phase)
        _scenario = State(initialValue: launchState.scenario)
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = AIChatMetrics(proxy: proxy)

            ZStack(alignment: .top) {
                BONColor.backgroundPrimary
                    .ignoresSafeArea()

                BONSiriEdgeGlow(isActive: didAppear && !reduceTransparency)
                    .opacity(phase == .focusedEmpty || phase == .typing ? 0.58 : 0.86)
                    .ignoresSafeArea()

                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            AIChatIntroBlock()

                            if sentPrompt == nil {
                                AIChatSuggestionStack(isVisible: showsInitialSuggestions) { prompt in
                                    submit(prompt)
                                }
                                .padding(.top, showsInitialSuggestions ? 26 : 0)
                            }

                            if let sentPrompt {
                                HStack {
                                    Spacer(minLength: 0)
                                    BONChatChip(text: sentPrompt, style: .sent) {
                                    }
                                }
                                .padding(.top, showsInitialSuggestions ? 24 : 24)
                            }

                            if phase == .thinking {
                                Text("Thinking...")
                                    .font(BONTypography.zalando(size: 12, weight: .medium))
                                    .foregroundStyle(BONColor.accentLime)
                                    .opacity(didAppear ? 1 : 0.35)
                                    .animation(BONMotion.thinkingPulse, value: didAppear)
                                    .frame(width: metrics.contentWidth, alignment: .leading)
                                    .padding(.top, 16)
                            }

                            if phase == .responded, let scenario {
                                AIChatScenarioResponse(scenario: scenario, onSuggestionSelect: submit)
                                    .padding(.top, 16)
                            }

                            Color.clear
                                .frame(height: 96)
                                .id(bottomAnchorID)
                        }
                        .frame(width: metrics.contentWidth, alignment: .leading)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, metrics.contentTop)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .onChange(of: phase) { _, _ in
                        scrollToBottom(scrollProxy)
                    }
                    .onChange(of: sentPrompt) { _, _ in
                        scrollToBottom(scrollProxy)
                    }
                    .onAppear {
                        scrollToLaunchTargetIfNeeded(scrollProxy)
                    }
                }

                AIChatTopScrim()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .ignoresSafeArea(.container, edges: .top)
                    .allowsHitTesting(false)

                BONChatTopBar(
                    onMenu: {
                        BONHaptics.selection()
                    },
                    onHome: {
                        dismiss()
                    }
                )
                .frame(width: metrics.contentWidth, height: 40)
                .position(x: proxy.size.width / 2, y: metrics.topBarCenterY)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                BONChatComposer(
                    text: $draft,
                    focused: $composerFocused,
                    isThinking: phase == .thinking,
                    onSend: {
                        submitCurrentDraft()
                    },
                    onCancelThinking: {
                        finishThinkingNow()
                    }
                )
                .frame(width: metrics.contentWidth, height: 64)
                .padding(.bottom, metrics.composerBottomPadding)
                .frame(maxWidth: .infinity)
                .background(Color.clear)
            }
            .opacity(didAppear || reduceMotion ? 1 : 0.96)
            .scaleEffect(didAppear || reduceMotion ? 1 : 0.985)
            .animation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.matchedMorph, value: didAppear)
            .onAppear {
                didAppear = true
                applyLaunchFocusIfNeeded()
            }
            .onDisappear {
                responseTask?.cancel()
            }
            .onChange(of: composerFocused) { _, isFocused in
                guard sentPrompt == nil else {
                    return
                }

                if isFocused && draft.isEmpty {
                    setPhase(.focusedEmpty)
                } else if !isFocused && draft.isEmpty {
                    setPhase(.initial)
                }
            }
            .onChange(of: draft) { _, newValue in
                guard sentPrompt == nil else {
                    return
                }

                if newValue.isEmpty {
                    setPhase(composerFocused ? .focusedEmpty : .initial)
                } else {
                    setPhase(.typing)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(.container, edges: .top)
    }

    private var showsInitialSuggestions: Bool {
        sentPrompt == nil && phase != .typing
    }

    private func submitCurrentDraft() {
        let prompt = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, phase != .thinking else {
            composerFocused = true
            return
        }

        submit(prompt)
    }

    private func submit(_ prompt: String) {
        responseTask?.cancel()
        let routedScenario = AIChatScenarioRouter.route(prompt)

        withAnimation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.reveal) {
            composerFocused = false
            draft = ""
            sentPrompt = prompt
            scenario = routedScenario
            phase = .thinking
        }

        responseTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(820))
            guard !Task.isCancelled else {
                return
            }

            withAnimation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.reveal) {
                phase = .responded
            }
        }
    }

    private func finishThinkingNow() {
        responseTask?.cancel()
        withAnimation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.reveal) {
            phase = .responded
        }
    }

    private func setPhase(_ nextPhase: AIChatPhase) {
        guard phase != nextPhase else {
            return
        }

        withAnimation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.chatSuggestionFlow) {
            phase = nextPhase
        }
    }

    private func scrollToBottom(_ scrollProxy: ScrollViewProxy) {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(60))
            withAnimation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.scrollPolish) {
                scrollProxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        }
    }

    private func scrollToLaunchTargetIfNeeded(_ scrollProxy: ScrollViewProxy) {
        guard let launchScrollTarget, !didApplyLaunchScroll else {
            return
        }

        didApplyLaunchScroll = true

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(180))
            scrollProxy.scrollTo(launchScrollTarget.rawValue, anchor: .center)
        }
    }

    private func applyLaunchFocusIfNeeded() {
        let launchState = AIChatLaunchState.fromLaunchArguments()
        guard launchState.shouldFocusComposer else {
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(240))
            composerFocused = true
        }
    }
}

private struct AIChatTopScrim: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color.white.opacity(0.995), location: 0.0),
                .init(color: Color.white.opacity(0.98), location: 0.58),
                .init(color: Color.white.opacity(0.0), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 150)
        .blur(radius: reduceTransparency ? 0 : 1)
    }
}

private enum AIChatPhase: String {
    case initial
    case focusedEmpty
    case typing
    case thinking
    case responded
}

private struct AIChatLaunchState {
    let phase: AIChatPhase
    let draft: String
    let sentPrompt: String?
    let scenario: AIChatScenario?
    let shouldFocusComposer: Bool
    let scrollTarget: AIChatLaunchScrollTarget?

    static func fromLaunchArguments() -> AIChatLaunchState {
        let arguments = ProcessInfo.processInfo.arguments
        let stateValue = argumentValue(after: "-BONAIChatState", in: arguments)?.lowercased()
        let prompt = argumentValue(after: "-BONAIChatPrompt", in: arguments)
        let scenario = AIChatScenario.fromLaunchArgument(argumentValue(after: "-BONAIChatScenario", in: arguments))
        let scrollTarget = AIChatLaunchScrollTarget(rawValue: argumentValue(after: "-BONAIChatScrollTarget", in: arguments) ?? "")

        switch stateValue {
        case "keyboard-empty":
            return AIChatLaunchState(phase: .focusedEmpty, draft: "", sentPrompt: nil, scenario: nil, shouldFocusComposer: true, scrollTarget: scrollTarget)
        case "typed":
            return AIChatLaunchState(
                phase: .typing,
                draft: prompt ?? AIChatScenario.creditImprove.defaultPrompt,
                sentPrompt: nil,
                scenario: nil,
                shouldFocusComposer: true,
                scrollTarget: scrollTarget
            )
        case "thinking":
            let sent = prompt ?? scenario?.defaultPrompt ?? AIChatScenario.creditImprove.defaultPrompt
            return AIChatLaunchState(
                phase: .thinking,
                draft: "",
                sentPrompt: sent,
                scenario: scenario ?? AIChatScenarioRouter.route(sent),
                shouldFocusComposer: false,
                scrollTarget: scrollTarget
            )
        case "response":
            let resolvedScenario = scenario ?? .creditImprove
            return AIChatLaunchState(
                phase: .responded,
                draft: "",
                sentPrompt: prompt ?? resolvedScenario.defaultPrompt,
                scenario: resolvedScenario,
                shouldFocusComposer: false,
                scrollTarget: scrollTarget
            )
        default:
            return AIChatLaunchState(phase: .initial, draft: "", sentPrompt: nil, scenario: nil, shouldFocusComposer: false, scrollTarget: scrollTarget)
        }
    }

    static let initial = AIChatLaunchState(phase: .initial, draft: "", sentPrompt: nil, scenario: nil, shouldFocusComposer: false, scrollTarget: nil)

    private static func argumentValue(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else {
            return nil
        }

        return arguments[index + 1]
    }
}

private enum AIChatLaunchScrollTarget: String {
    case creditImproveActionCard = "credit-improve-action-card"
    case creditImproveCuratedPath = "credit-improve-curated-path"
    case creditDropPaymentHistory = "credit-drop-payment-history"
    case creditDropHardInquiries = "credit-drop-hard-inquiries"
    case budgetSpendingOverview = "budget-spending-overview"
}

private struct AIChatMetrics {
    let contentWidth: CGFloat
    let contentTop: CGFloat
    let topBarCenterY: CGFloat
    let composerBottomPadding: CGFloat

    init(proxy: GeometryProxy) {
        let safeBottom = proxy.safeAreaInsets.bottom
        contentWidth = min(354, max(0, proxy.size.width - 48))
        topBarCenterY = 94
        contentTop = 146
        composerBottomPadding = max(14, 48 - safeBottom)
    }
}

private enum AIChatScenario: String, CaseIterable, Identifiable {
    case creditImprove
    case creditDrop
    case budgetSpending
    case budgetTimeline
    case budgetRunway
    case debtCards
    case debtPath
    case fallback

    var id: String { rawValue }

    var defaultPrompt: String {
        switch self {
        case .creditImprove:
            return "I want to improve my credit score"
        case .creditDrop:
            return "Why’s my score continuously dropping right now?"
        case .budgetSpending:
            return "Show me my monthly spending"
        case .budgetTimeline:
            return "How’s my budget for this month going on so far?"
        case .budgetRunway:
            return "How I’m doing so for this month? Anything I like to keep in mind?"
        case .debtCards:
            return "Show me my credit cards and balances on each of them"
        case .debtPath:
            return "What’s the best path forward for me, so that I don’t get into debt again?"
        case .fallback:
            return "What else could you do for me?"
        }
    }

    static func fromLaunchArgument(_ value: String?) -> AIChatScenario? {
        guard let value else {
            return nil
        }

        switch value.lowercased() {
        case "credit-improve", "improve-score":
            return .creditImprove
        case "credit-drop", "score-dropping":
            return .creditDrop
        case "budget-spending", "monthly-spending":
            return .budgetSpending
        case "budget-timeline":
            return .budgetTimeline
        case "budget-runway", "bills-runway":
            return .budgetRunway
        case "debt-cards", "card-balances":
            return .debtCards
        case "debt-path", "debt-prevention":
            return .debtPath
        case "fallback":
            return .fallback
        default:
            return nil
        }
    }
}

private enum AIChatScenarioRouter {
    static func route(_ prompt: String) -> AIChatScenario {
        let normalized = prompt.lowercased()

        if normalized.contains("score") || normalized.contains("credit report") || normalized.contains("inquiries") {
            if normalized.contains("drop") || normalized.contains("dropping") || normalized.contains("why") || normalized.contains("history") {
                return .creditDrop
            }
            return .creditImprove
        }

        if normalized.contains("budget") || normalized.contains("spending") || normalized.contains("dining") || normalized.contains("monthly") {
            if normalized.contains("monthly spending") || normalized.contains("spending") || normalized.contains("dining") {
                return .budgetSpending
            }
            if normalized.contains("runway") || normalized.contains("keep in mind") || normalized.contains("doing so far") {
                return .budgetRunway
            }
            if normalized.contains("going") || normalized.contains("timeline") || normalized.contains("month") {
                return .budgetTimeline
            }
            return .budgetSpending
        }

        if normalized.contains("card") || normalized.contains("balance") || normalized.contains("debt") || normalized.contains("interest") {
            if normalized.contains("path") || normalized.contains("forward") || normalized.contains("again") || normalized.contains("prevent") {
                return .debtPath
            }
            return .debtCards
        }

        if normalized.contains("show me that card") {
            return .debtCards
        }

        return .fallback
    }
}

private struct BONChatTopBar: View {
    let onMenu: () -> Void
    let onHome: () -> Void

    var body: some View {
        topBarContent
    }

    private var topBarContent: some View {
        HStack {
            Button(action: onMenu) {
                BONChatTopIconControl(imageAsset: "chatMenu")
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel("Menu")

            Spacer()

            BONChatExpertPillSurface()
                .frame(width: 154, height: 40)
                .overlay {
                    Text("Talk to human expert")
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .foregroundStyle(BONColor.textOnDark)
                }
                .accessibilityLabel("Talk to human expert")

            Spacer()

            Button(action: onHome) {
                BONChatTopIconControl(imageAsset: "navHome")
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel("Home")
        }
    }
}

private struct BONChatTopIconControl: View {
    private let systemName: String?
    private let imageAsset: String?
    private let iconSize: CGFloat

    init(systemName: String, iconSize: CGFloat = 16) {
        self.systemName = systemName
        self.imageAsset = nil
        self.iconSize = iconSize
    }

    init(imageAsset: String, iconSize: CGFloat = 16) {
        self.systemName = nil
        self.imageAsset = imageAsset
        self.iconSize = iconSize
    }

    var body: some View {
        BONChatTopIconSurface()
            .overlay {
                icon
            }
            .frame(width: 40, height: 40)
            .contentShape(Circle())
    }

    @ViewBuilder
    private var icon: some View {
        if let imageAsset {
            Image(imageAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: iconSize, height: iconSize)
        } else if let systemName {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(BONColor.textPrimary)
        }
    }
}

private struct BONChatTopIconSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let circle = Circle()

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                circle
                    .fill(Color.white.opacity(0.035))

                circle
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.34),
                                Color.white.opacity(0.07),
                                Color.white.opacity(0.01)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 48
                        )
                    )
                    .blendMode(.screen)

                circle
                    .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.7)
                    .blur(radius: 0.35)
                    .opacity(0.44)
            }
            .clipShape(circle)
            .glassEffect(.regular.tint(Color.white.opacity(0.18)).interactive(), in: circle)
            .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
            .shadow(color: BONColor.limeGlow.opacity(0.08), radius: 20, x: 0, y: 0)
        } else {
            circle
                .fill(reduceTransparency ? Color.white : Color.white.opacity(0.76))
                .overlay(
                    circle
                        .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.055), radius: 18, x: 0, y: 8)
        }
    }
}

private struct BONChatExpertPillSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.82), location: 0.0),
                                .init(color: Color.black.opacity(0.70), location: 0.55),
                                .init(color: Color.black.opacity(0.80), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                capsule
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.24),
                                Color.white.opacity(0.04),
                                Color.black.opacity(0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.softLight)

                capsule
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    .blur(radius: 0.35)
                    .opacity(0.58)
            }
            .clipShape(capsule)
            .glassEffect(.regular.tint(Color.black.opacity(0.74)).interactive(), in: capsule)
            .shadow(color: Color.black.opacity(0.19), radius: 11, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.075), radius: 22, x: 0, y: 16)
        } else {
            capsule
                .fill(Color.black.opacity(reduceTransparency ? 0.88 : 0.82))
                .overlay(
                    capsule
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)
        }
    }
}

private struct AIChatIntroBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Hey Marcus, here’s what I found:")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 22, alignment: .leading)

            Text("$5250/yr")
                .font(BONTypography.geistPixel(size: 24))
                .tracking(-0.48)
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 31, alignment: .leading)
                .padding(.top, 12)

            (Text("going to ")
                + Text("credit card interest.").bold()
                + Text(" That's $14 every single day, gone."))
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineSpacing(3)
                .frame(height: 48, alignment: .leading)
                .padding(.top, 4)

            Text("Most of this is fixable. Want me to start with the card costing you the most?")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineSpacing(3)
                .frame(height: 48, alignment: .leading)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct AIChatSuggestionStack: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let isVisible: Bool
    let onSelect: (String) -> Void

    private let prompts: [(text: String, width: CGFloat)] = [
        ("Yes, show me that card", 180),
        ("What else you could do for me?", 232),
        ("What else you could do for me?", 232)
    ]
    private let expandedHeight: CGFloat = 156

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 12) {
                ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                    BONChatChip(text: prompt.text, style: .suggestion, width: prompt.width) {
                        onSelect(prompt.text)
                    }
                    .opacity(chipOpacity(for: index))
                    .scaleEffect(chipScale(for: index), anchor: .trailing)
                    .offset(chipOffset(for: index))
                }
            }
            .scaleEffect(stackScale, anchor: .topTrailing)
            .opacity(isVisible ? 1 : 0)
        }
        .frame(height: isVisible ? expandedHeight : 0, alignment: .topTrailing)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .clipped()
        .allowsHitTesting(isVisible)
        .accessibilityHidden(!isVisible)
        .animation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.chatSuggestionFlow, value: isVisible)
    }

    private var stackScale: CGSize {
        if reduceMotion || isVisible {
            return CGSize(width: 1, height: 1)
        }

        return CGSize(width: 0.78, height: 0.72)
    }

    private func chipOpacity(for index: Int) -> Double {
        if isVisible {
            return 1
        }

        return reduceMotion ? 0 : max(0, 0.16 - Double(index) * 0.04)
    }

    private func chipScale(for index: Int) -> CGSize {
        if reduceMotion || isVisible {
            return CGSize(width: 1, height: 1)
        }

        let adjustment = CGFloat(index) * 0.035
        return CGSize(width: 0.72 - adjustment, height: 0.64 - adjustment)
    }

    private func chipOffset(for index: Int) -> CGSize {
        if reduceMotion || isVisible {
            return .zero
        }

        return CGSize(width: 24 + CGFloat(index) * 6, height: -10 - CGFloat(index) * 12)
    }
}

private enum BONChatChipStyle {
    case suggestion
    case sent
    case responseSuggestion
}

private struct BONChatChip: View {
    let text: String
    let style: BONChatChipStyle
    var width: CGFloat? = nil
    var action: () -> Void

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            Text(text)
                .font(BONTypography.zalando(size: style.fontSize, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineLimit(resolvedLineLimit)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(style.minimumScaleFactor)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(width: resolvedWidth, alignment: .leading)
                .frame(minHeight: style.minHeight)
                .background(
                    bubbleShape
                        .fill(background)
                        .overlay(
                            bubbleShape
                                .stroke(strokeColor, lineWidth: strokeLineWidth)
                        )
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(text)
    }

    private var bubbleShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: style.cornerRadius,
            bottomLeadingRadius: style.cornerRadius,
            bottomTrailingRadius: 0,
            topTrailingRadius: style.cornerRadius,
            style: .continuous
        )
    }

    private var resolvedWidth: CGFloat? {
        if let width {
            return min(width, maxPromptWidth)
        }

        guard style.limitsPromptWidth, estimatedChipWidth > maxPromptWidth else {
            return nil
        }

        return maxPromptWidth
    }

    private var maxPromptWidth: CGFloat {
        floor(UIScreen.main.bounds.width * 0.65)
    }

    private var estimatedChipWidth: CGFloat {
        let averageGlyphWidth = style.fontSize * style.averageGlyphWidthMultiplier
        return CGFloat(text.count) * averageGlyphWidth + 32
    }

    private var resolvedLineLimit: Int {
        if style == .sent, text.count <= 34 {
            return 1
        }

        return style.lineLimit
    }

    private var background: Color {
        switch style {
        case .suggestion, .responseSuggestion:
            return BONColor.accentLime
        case .sent:
            return Color(red: 0.925, green: 1.0, blue: 0.78)
        }
    }

    private var strokeColor: Color {
        switch style {
        case .suggestion, .responseSuggestion:
            return Color.clear
        case .sent:
            return BONColor.accentLime.opacity(0.35)
        }
    }

    private var strokeLineWidth: CGFloat {
        style == .sent ? 1 : 0
    }
}

private extension BONChatChipStyle {
    var fontSize: CGFloat {
        switch self {
        case .sent:
            return 16
        case .suggestion, .responseSuggestion:
            return 14
        }
    }

    var lineLimit: Int {
        switch self {
        case .suggestion:
            return 1
        case .sent, .responseSuggestion:
            return 2
        }
    }

    var minimumScaleFactor: CGFloat {
        switch self {
        case .suggestion, .responseSuggestion:
            return 0.92
        case .sent:
            return 0.92
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .sent:
            return 48
        case .suggestion, .responseSuggestion:
            return 44
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .sent:
            return 20
        case .suggestion, .responseSuggestion:
            return 22
        }
    }

    var limitsPromptWidth: Bool {
        true
    }

    var averageGlyphWidthMultiplier: CGFloat {
        switch self {
        case .sent:
            return 0.56
        case .suggestion, .responseSuggestion:
            return 0.52
        }
    }
}

private struct BONChatComposer: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @Binding var text: String
    var focused: FocusState<Bool>.Binding
    let isThinking: Bool
    let onSend: () -> Void
    let onCancelThinking: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if isThinking {
                    Text("Thinking...")
                        .font(BONTypography.zalando(size: 14, weight: .regular))
                        .foregroundStyle(BONColor.textOnDark.opacity(0.72))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text("Ask BON Credit...")
                            .foregroundStyle(BONColor.textOnDark.opacity(0.58))
                    )
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textOnDark)
                    .submitLabel(.send)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.sentences)
                    .focused(focused)
                    .tint(BONColor.textOnDark)
                    .onSubmit(onSend)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.leading, 24)

            Button {
                isThinking ? onCancelThinking() : onSend()
            } label: {
                ZStack {
                    BONChatComposerActionSurface()

                    composerIcon
                }
                .frame(width: 72, height: 52)
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel(isThinking ? "Stop thinking" : (hasDraft ? "Send message" : "Voice input"))
            .padding(.trailing, 6)
        }
        .frame(height: 64)
        .background(BONChatGlassCapsule())
        .contentShape(Capsule(style: .continuous))
        .onTapGesture {
            if !isThinking {
                focused.wrappedValue = true
            }
        }
    }

    private var composerIcon: some View {
        ZStack {
            Image("chatVoice")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(BONColor.textOnDark)
                .frame(width: 16, height: 16)
                .opacity(iconMode == .voice ? 1 : 0)
                .scaleEffect(reduceMotion ? 1 : (iconMode == .voice ? 1 : 0.72))
                .rotationEffect(.degrees(reduceMotion ? 0 : (iconMode == .voice ? 0 : -14)))
                .blur(radius: reduceMotion ? 0 : (iconMode == .voice ? 0 : 1.2))

            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(BONColor.textOnDark)
                .opacity(iconMode == .send ? 1 : 0)
                .scaleEffect(reduceMotion ? 1 : (iconMode == .send ? 1 : 0.66))
                .rotationEffect(.degrees(reduceMotion ? 0 : (iconMode == .send ? 0 : 16)))
                .offset(y: reduceMotion ? 0 : (iconMode == .send ? 0 : 4))
                .blur(radius: reduceMotion ? 0 : (iconMode == .send ? 0 : 1.0))

            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(BONColor.textOnDark)
                .frame(width: 14, height: 14)
                .opacity(iconMode == .stop ? 1 : 0)
                .scaleEffect(reduceMotion ? 1 : (iconMode == .stop ? 1 : 0.62))
                .blur(radius: reduceMotion ? 0 : (iconMode == .stop ? 0 : 1.0))
        }
        .frame(width: 20, height: 20)
        .animation(reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.chatIconMorph, value: iconMode)
    }

    private var hasDraft: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var iconMode: BONChatComposerIconMode {
        if isThinking {
            return .stop
        }

        return hasDraft ? .send : .voice
    }
}

private enum BONChatComposerIconMode: Hashable {
    case voice
    case send
    case stop
}

private struct BONChatComposerActionSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                capsule
                    .fill(Color.black.opacity(0.30))
                    .glassEffect(.regular.tint(Color.black.opacity(0.56)).interactive(), in: capsule)

                capsule
                    .fill(Color(red: 0.285, green: 0.285, blue: 0.275).opacity(0.94))

                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.10), location: 0.0),
                                .init(color: Color.white.opacity(0.045), location: 0.34),
                                .init(color: Color.black.opacity(0.20), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.softLight)

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.055),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 58
                        )
                    )
                    .blendMode(.screen)

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.18),
                                Color.black.opacity(0.055),
                                Color.clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 74
                        )
                    )
                    .blendMode(.multiply)
            }
            .clipShape(capsule)
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
        } else {
            ZStack {
                capsule
                    .fill(Color(red: 0.25, green: 0.25, blue: 0.24).opacity(reduceTransparency ? 0.96 : 0.90))

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.025),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 58
                        )
                    )

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.24),
                                Color.black.opacity(0.08),
                                Color.clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 74
                        )
                    )
            }
            .clipShape(capsule)
            .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
        }
    }
}

private struct BONChatGlassCapsule: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        let surface = ZStack {
            if reduceTransparency {
                capsule.fill(Color.black.opacity(0.90))
            } else {
                if #available(iOS 26.0, *) {
                    capsule
                        .fill(Color.black.opacity(0.46))
                        .glassEffect(.regular.tint(Color.black.opacity(0.82)).interactive(), in: capsule)
                } else {
                    capsule.fill(.ultraThinMaterial)
                }

                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.92), location: 0.0),
                                .init(color: Color.black.opacity(0.82), location: 0.52),
                                .init(color: Color.black.opacity(0.91), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            capsule
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.090),
                            Color.clear,
                            Color.black.opacity(0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.softLight)

            capsule
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.clear, location: 0.18),
                            .init(color: Color.white.opacity(0.050), location: 0.48),
                            .init(color: Color.clear, location: 0.70)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .blendMode(.screen)

            capsule
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.025),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 112
                    )
                )
                .blendMode(.screen)

            capsule
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.22),
                            Color.black.opacity(0.08),
                            Color.clear
                        ],
                        center: .trailing,
                        startRadius: 12,
                        endRadius: 126
                    )
                )
                .blendMode(.multiply)
        }
        .clipShape(capsule)

        if #available(iOS 26.0, *), !reduceTransparency {
            surface
                .shadow(color: Color.black.opacity(0.20), radius: 14, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.11), radius: 30, x: 0, y: 24)
        } else {
            surface
                .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.10), radius: 28, x: 0, y: 24)
        }
    }
}

private struct BONSiriEdgeGlow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Double = 0

    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            let cornerRadius = min(58, max(42, proxy.size.width * 0.12))
            let animatedGradient = AngularGradient(
                colors: [
                    BONColor.lime50.opacity(0.18),
                    BONColor.lime100.opacity(0.52),
                    BONColor.lime200.opacity(0.78),
                    BONColor.lime300.opacity(0.68),
                    BONColor.lime100.opacity(0.42),
                    BONColor.lime50.opacity(0.18)
                ],
                center: .center,
                angle: .degrees(phase)
            )

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(animatedGradient, lineWidth: 2.4)
                    .blur(radius: 5.5)
                    .padding(7)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(animatedGradient, lineWidth: 1.1)
                    .blur(radius: 11)
                    .padding(1)
                    .opacity(0.72)

                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            BONColor.lime300.opacity(0.18),
                            BONColor.lime200.opacity(0.14),
                            BONColor.lime100.opacity(0.08),
                            BONColor.lime50.opacity(0.03),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 18)

                    Spacer(minLength: 0)

                    LinearGradient(
                        colors: [
                            .clear,
                            BONColor.lime50.opacity(0.03),
                            BONColor.lime100.opacity(0.08),
                            BONColor.lime200.opacity(0.14),
                            BONColor.lime300.opacity(0.18)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 18)
                }
                .blur(radius: 9)
            }
            .scaleEffect(isActive && !reduceMotion ? 1.006 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isActive)
        }
        .allowsHitTesting(false)
        .onAppear {
            guard !reduceMotion else {
                return
            }

            withAnimation(.linear(duration: 5.4).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

private struct AIChatScenarioResponse: View {
    let scenario: AIChatScenario
    let onSuggestionSelect: (String) -> Void

    init(
        scenario: AIChatScenario,
        onSuggestionSelect: @escaping (String) -> Void = { _ in }
    ) {
        self.scenario = scenario
        self.onSuggestionSelect = onSuggestionSelect
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch scenario {
            case .creditImprove:
                creditImprove
            case .creditDrop:
                creditDrop
            case .budgetSpending:
                budgetSpending
            case .budgetTimeline:
                budgetTimeline
            case .budgetRunway:
                budgetRunway
            case .debtCards:
                debtCards
            case .debtPath:
                debtPath
            case .fallback:
                fallback
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var creditImprove: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sure. Your credit score is 614. I’d say that’s not bad and needs little bit improvement. I can see you lost 60 points in last 6 months.")
                Text("Let’s reverse this trend, here’s how you can improve your credit score:")
            }
            .chatBodyText()

            AIChatSection(title: "Action card for you") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            BONChatTag("Quick Win #1", style: .lime)
                            Text("Free    |    Easy")
                                .font(BONTypography.zalando(size: 14, weight: .regular))
                                .foregroundStyle(BONColor.textPrimary)
                                .frame(height: 17, alignment: .leading)
                        }

                        Text("Pay before your statement closes")
                            .chatCardTitle()

                        AIChatMetricBox(label: "Expected lift", value: "+5 to +15 pts", footnote: "in 30 days")

                        AIChatHowSteps(steps: [
                            "Your Chase statement closes May 24.",
                            "Pay $5,920 by May 23 to drop reported balance to $2,500.",
                            "Score updates next bureau pull, usually 5-10 days after."
                        ])

                        BONChatPrimaryActionButton(title: "Schedule payment")
                            .frame(height: 48)
                    }
                }
            }
            .id(AIChatLaunchScrollTarget.creditImproveActionCard.rawValue)

            AIChatSection(title: "Curated path") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 16) {
                        BONChatTag("Estimated 90 days", style: .lime)

                        Text("Get to 700+ in 3 months.")
                            .chatCardTitle()

                        HStack(spacing: 0) {
                            AIChatMonthCard(month: "MONTH 1", title: "Pay Chase credit card to 28%", result: "+15 pts est", tone: .first)
                            AIChatMonthCard(month: "MONTH 2", title: "Goodwill on Capital One late", result: "+25 pts if granted", tone: .middle)
                            AIChatMonthCard(month: "MONTH 3", title: "Pay before statement habit", result: "+10 pts compounding", tone: .last)
                        }
                        .frame(height: 145)

                        AIChatScorePath()
                    }
                }
            }
            .id(AIChatLaunchScrollTarget.creditImproveCuratedPath.rawValue)
        }
    }

    private var creditDrop: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Good question. Actually this is because of multiple reasons.")
                .chatBodyText()

            BONChatResponseCard(height: 326, shadowRadius: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    BONChatTag("Payment History", style: .lime)

                    Text("Multiple late payments in last 24 months.")
                        .chatCardTitle()

                    AIChatPaymentHistoryRows()
                        .frame(height: 193)
                }
            }
            .overlay(alignment: .bottom) {
                AIChatViewAllButton(direction: .up, hasShadow: true)
                    .offset(y: 16)
            }
            .padding(.bottom, 16)
            .id(AIChatLaunchScrollTarget.creditDropPaymentHistory.rawValue)

            BONChatResponseCard(height: 324, shadowRadius: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    BONChatTag("Hard Inquiries", style: .lime)

                    Text("3 in last 12 months. Let them age out.")
                        .chatCardTitle()

                    VStack(spacing: 8) {
                        AIChatHardInquiryRow(title: "Citi (auto loan)", age: "8 mo ago", points: "- 5 pts")
                        AIChatHardInquiryRow(title: "Apple card", age: "5 mo ago", points: "- 5 pts")
                        AIChatHardInquiryRow(title: "Chase Sapphire", age: "2 mo ago", points: "- 3 pts")
                    }
                }
            }
            .id(AIChatLaunchScrollTarget.creditDropHardInquiries.rawValue)
        }
    }

    private var budgetSpending: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Here’s your month at a glance.")
                .chatBodyText()

            AIChatMonthlySpendingCard()
                .id(AIChatLaunchScrollTarget.budgetSpendingOverview.rawValue)
        }
    }

    private var budgetTimeline: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Here’s your timeline for this month’s budget.")
                .chatBodyText()

            AIChatSection(title: "Your budget") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("money left to spend")
                                    .chatCaption()
                                Text("$525")
                                    .font(BONTypography.geistPixel(size: 32))
                                    .tracking(-0.64)
                            }

                            Spacer()
                            BONChatTag("May 01 - May 18", style: .neutral)
                        }

                        AIChatBudgetTimelineChart()
                            .frame(height: 152)

                        HStack {
                            AIChatSmallMetric(title: "Money in", value: "$6,094")
                            Spacer()
                            AIChatSmallMetric(title: "Money out", value: "$5,569")
                            Spacer()
                            AIChatSmallMetric(title: "Pace", value: "On track", alignment: .trailing)
                        }
                    }
                }
            }

            AIChatSection(title: "Income volatility") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your income swings between $400 and $1200 a week.")
                            .chatCardTitle()
                        AIChatIncomeBars()
                            .frame(height: 150)
                        Text("Plan around: the lower end first, then treat upside weeks as debt-payoff boosts.")
                            .chatBodyText()
                    }
                }
            }
        }
    }

    private var budgetRunway: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Great Marcus, you’re asking good questions now. Let me give you detail Runway of yours.")
                .chatBodyText()

            AIChatSection(title: "Bills runway") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            AIChatSmallMetric(title: "Cash on hand", value: "$1,847")
                            Spacer()
                            AIChatSmallMetric(title: "Next paycheck", value: "May 22 | ~$650", alignment: .trailing)
                        }

                        AIChatRunwayTimeline()
                            .frame(height: 250)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("My take")
                                .chatCaption()
                            Text("You stay above zero through bills and reach the next paycheck with about a $77 buffer. Tight, but safe. Hold off Chase until May 22.")
                                .chatBodyText()
                        }
                    }
                }
            }
        }
    }

    private var debtCards: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("In your credit report you’ve 12 active credit cards and 4 closed cards.")
                .chatBodyText()

            AIChatSection(title: "Active cards") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total credit card balance")
                                .chatCaption()
                            Text("$26,893")
                                .font(BONTypography.geistPixel(size: 32))
                                .tracking(-0.64)
                        }

                        Text("Costing you about $285/mo in interest alone")
                            .chatBodyText()

                        AIChatAccountRows(rows: AIChatAccountRow.debtRows)
                        AIChatViewAllButton()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("My take")
                                .chatCaption()
                            Text("Chase Sapphire is the leak: about $170/mo interest and 91% utilized. Discover is past due. Fix starts with Chase.")
                                .chatBodyText()
                        }
                    }
                }
            }
        }
    }

    private var debtPath: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("In your credit report you’ve 12 active credit cards and 4 closed cards.")
                .chatBodyText()

            AIChatSection(title: "Active cards") {
                BONChatResponseCard {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            AIChatSmallMetric(title: "Emergency fund", value: "$2,500")
                            Spacer()
                            AIChatSmallMetric(title: "Goal", value: "$1,000", alignment: .trailing)
                        }

                        AIChatProgressLine(title: "Starter emergency fund", value: "$1,000", progress: 0.40)
                        AIChatAccountRows(rows: AIChatAccountRow.debtRows)
                        AIChatViewAllButton()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("My take")
                                .chatCaption()
                            Text("Build the first $1,000 buffer before aggressive payoff. Then use every surplus week to attack Chase while keeping minimums automated.")
                                .chatBodyText()
                        }
                    }
                }
            }
        }
    }

    private var fallback: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("I can help with credit score, budgeting, or debt payoff. Pick one and I will show the next best action.")
                .chatBodyText()

            VStack(alignment: .trailing, spacing: 12) {
                BONChatChip(text: AIChatScenario.creditImprove.defaultPrompt, style: .responseSuggestion) {
                    onSuggestionSelect(AIChatScenario.creditImprove.defaultPrompt)
                }
                BONChatChip(text: AIChatScenario.budgetSpending.defaultPrompt, style: .responseSuggestion) {
                    onSuggestionSelect(AIChatScenario.budgetSpending.defaultPrompt)
                }
                BONChatChip(text: AIChatScenario.debtCards.defaultPrompt, style: .responseSuggestion) {
                    onSuggestionSelect(AIChatScenario.debtCards.defaultPrompt)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct AIChatSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 17, alignment: .leading)

            content
        }
    }
}

private struct BONChatResponseCard<Content: View>: View {
    let content: Content
    let height: CGFloat?
    let shadowRadius: CGFloat

    init(
        height: CGFloat? = nil,
        shadowRadius: CGFloat = 32,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.height = height
        self.shadowRadius = shadowRadius
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: shadowRadius, x: 0, y: 8)
            )
    }
}

private struct BONChatPrimaryActionButton: View {
    let title: String

    var body: some View {
        Button {
            BONHaptics.impact(.light)
        } label: {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textOnDark)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.black)
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

private enum BONChatTagStyle {
    case lime
    case neutral
}

private enum AIChatCreditGraphicColor {
    static let stepBadge = Color(red: 0.957, green: 0.984, blue: 0.906)
    static let pathInk = Color(red: 0.071, green: 0.278, blue: 0.173)
    static let pathMutedInk = Color(red: 0.290, green: 0.600, blue: 0.455)
    static let monthOne = Color(red: 0.871, green: 0.945, blue: 0.906)
    static let progressStart = Color(red: 0.906, green: 1.0, blue: 0.639)
    static let progressEnd = Color(red: 0.537, green: 0.694, blue: 0.149)
    static let lateGreen = BONColor.lime600
    static let lateRed = Color(red: 0.780, green: 0.0, blue: 0.0)
    static let inquiryRow = Color(red: 0.969, green: 0.969, blue: 0.969)
}

private struct BONChatTag: View {
    let title: String
    let style: BONChatTagStyle

    init(_ title: String, style: BONChatTagStyle) {
        self.title = title
        self.style = style
    }

    var body: some View {
        Text(title)
            .font(BONTypography.zalando(size: 14, weight: .regular))
            .foregroundStyle(BONColor.textPrimary)
            .padding(.horizontal, 12)
            .frame(height: 33)
            .background(
                Capsule(style: .continuous)
                    .fill(style == .lime ? BONColor.accentLime.opacity(0.08) : Color.white)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(style == .lime ? Color.clear : BONColor.borderSubtle, lineWidth: style == .lime ? 0 : 1)
                    )
            )
    }
}

private struct AIChatMetricBox: View {
    let label: String
    let value: String
    let footnote: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(BONColor.accentLime)
                .frame(height: 17, alignment: .leading)

            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text(value)
                    .font(BONTypography.zalando(size: 24, weight: .semibold))
                    .foregroundStyle(BONColor.accentLime)
                Text(footnote)
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.accentLime)
            }
            .frame(height: 29, alignment: .bottom)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black)
        )
    }
}

private struct AIChatHowSteps: View {
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How")
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 17, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(BONColor.lime700)
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(AIChatCreditGraphicColor.stepBadge))

                        Text(step)
                            .chatBodyText()
                            .frame(width: 235, alignment: .leading)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 229, maxHeight: 229, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
    }
}

private enum AIChatMonthTone: Equatable {
    case first
    case middle
    case last

    var background: Color {
        switch self {
        case .first:
            return AIChatCreditGraphicColor.monthOne
        case .middle:
            return BONColor.lime100
        case .last:
            return BONColor.lime200
        }
    }
}

private struct AIChatMonthCard: View {
    let month: String
    let title: String
    let result: String
    let tone: AIChatMonthTone

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(month)
                .font(BONTypography.zalando(size: 10, weight: .medium))
                .tracking(0.1)
                .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                .frame(height: 12, alignment: .leading)

            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result)
                .font(BONTypography.zalando(size: 12, weight: .medium))
                .foregroundStyle(AIChatCreditGraphicColor.pathMutedInk)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 145, maxHeight: 145, alignment: .topLeading)
        .background(monthShape.fill(tone.background))
    }

    private var monthShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: tone == .first ? 20 : 0,
            bottomLeadingRadius: tone == .first ? 20 : 0,
            bottomTrailingRadius: tone == .last ? 20 : 0,
            topTrailingRadius: tone == .last ? 20 : 0,
            style: .continuous
        )
    }
}

private struct AIChatScorePath: View {
    var body: some View {
        VStack(spacing: 16) {
            Rectangle()
                .fill(BONColor.borderSubtle)
                .frame(height: 1)

            HStack(alignment: .center, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today")
                        .font(BONTypography.zalando(size: 10, weight: .medium))
                        .tracking(0.1)
                        .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                        .textCase(.uppercase)
                    Text("614")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                }
                .frame(width: 34, height: 37, alignment: .leading)

                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(BONColor.borderSubtle)
                        .frame(width: 193, height: 6)

                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    AIChatCreditGraphicColor.progressStart,
                                    AIChatCreditGraphicColor.progressEnd
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 93, height: 6)
                }
                .frame(width: 193, height: 6)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("90 days")
                        .font(BONTypography.zalando(size: 10, weight: .medium))
                        .tracking(0.1)
                        .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                        .textCase(.uppercase)
                    Text("700+")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(AIChatCreditGraphicColor.pathInk)
                }
                .frame(width: 43, height: 37, alignment: .trailing)
            }
            .frame(width: 310, height: 37)
        }
    }
}

private struct AIChatPaymentHistoryRows: View {
    private let rows: [AIChatPaymentHistoryRow] = [
        AIChatPaymentHistoryRow(
            name: "Chase Sapphire - XX3452",
            amount: "$4,598",
            lateIndices: [5, 14]
        ),
        AIChatPaymentHistoryRow(
            name: "Amex Gold- XX5681",
            amount: "$12,598",
            lateIndices: [5, 14, 20, 21, 22]
        ),
        AIChatPaymentHistoryRow(
            name: "Amex Pink- XX6892",
            amount: "$598",
            lateIndices: [5, 14, 18, 21, 22]
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                AIChatPaymentHistoryRowView(row: row)

                if index < rows.count - 1 {
                    AIChatDivider()
                        .padding(.vertical, 16)
                }
            }
        }
    }
}

private struct AIChatPaymentHistoryRow: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let lateIndices: Set<Int>

    init(name: String, amount: String, lateIndices: Set<Int>) {
        self.name = name
        self.amount = amount
        self.lateIndices = lateIndices
    }
}

private struct AIChatPaymentHistoryRowView: View {
    let row: AIChatPaymentHistoryRow

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<24, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 100, style: .continuous)
                        .fill(row.lateIndices.contains(index) ? AIChatCreditGraphicColor.lateRed : AIChatCreditGraphicColor.lateGreen)
                        .frame(width: 9, height: 20)
                }
            }
            .frame(width: 308, height: 20, alignment: .leading)

            HStack {
                Text(row.name)
                Spacer(minLength: 8)
                Text(row.amount)
                    .multilineTextAlignment(.trailing)
            }
            .font(BONTypography.zalando(size: 12, weight: .regular))
            .foregroundStyle(BONColor.textPrimary)
            .frame(height: 15, alignment: .center)
        }
        .frame(height: 43, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.name), \(row.amount), late payments highlighted")
    }
}

private struct AIChatHardInquiryRow: View {
    let title: String
    let age: String
    let points: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(height: 17, alignment: .leading)

                Text(age)
                    .font(BONTypography.zalando(size: 14, weight: .light))
                    .foregroundStyle(Color(red: 0.467, green: 0.467, blue: 0.467))
                    .frame(height: 17, alignment: .leading)
            }

            Spacer(minLength: 12)

            Text(points)
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 15, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 64, maxHeight: 64, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AIChatCreditGraphicColor.inquiryRow)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(age), \(points)")
    }
}

private enum AIChatBudgetGraphicColor {
    static let panel = Color(red: 0.969, green: 0.969, blue: 0.969)
    static let caption = Color(red: 0.467, green: 0.467, blue: 0.467)
    static let heatmapCrimson = Color(red: 255.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0)
    static let heatmapRed = Color(red: 255.0 / 255.0, green: 92.0 / 255.0, blue: 92.0 / 255.0)
    static let heatmapPink = Color(red: 255.0 / 255.0, green: 187.0 / 255.0, blue: 187.0 / 255.0)
    static let heatmapBlush = Color(red: 255.0 / 255.0, green: 225.0 / 255.0, blue: 225.0 / 255.0)
    static let heatmapPeach = Color(red: 255.0 / 255.0, green: 239.0 / 255.0, blue: 229.0 / 255.0)
    static let heatmapCream = Color(red: 255.0 / 255.0, green: 247.0 / 255.0, blue: 234.0 / 255.0)
    static let heatmapWarmCream = Color(red: 249.0 / 255.0, green: 246.0 / 255.0, blue: 208.0 / 255.0)
    static let heatmapPaleYellow = Color(red: 255.0 / 255.0, green: 251.0 / 255.0, blue: 217.0 / 255.0)
    static let heatmapLime100 = BONColor.lime100
    static let heatmapLime200 = BONColor.lime200
    static let heatmapLime300 = BONColor.lime300
    static let heatmapLime400Graph = Color(red: 180.0 / 255.0, green: 255.0 / 255.0, blue: 51.0 / 255.0)
    static let heatmapLime500 = BONColor.lime500
}

private struct AIChatMonthlySpendingCard: View {
    var body: some View {
        BONChatResponseCard(height: 344, shadowRadius: 32) {
            VStack(alignment: .leading, spacing: 20) {
                header
                    .frame(height: 59)

                AIChatMonthlySpendHeatmap()
                    .frame(width: 310, height: 156, alignment: .leading)

                AIChatMonthlySpendMetricStrip()
                    .frame(width: 310, height: 57, alignment: .leading)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("spent this month")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(AIChatBudgetGraphicColor.caption)
                    .frame(height: 15, alignment: .leading)

                Text("$6,136")
                    .font(BONTypography.geistPixel(size: 32, variant: .grid))
                    .tracking(-0.64)
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(height: 42, alignment: .leading)
            }
            .frame(width: 101, height: 59, alignment: .topLeading)

            Spacer(minLength: 0)

            AIChatBudgetFilterPill()
        }
    }
}

private struct AIChatBudgetFilterPill: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("All cards & bank")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .frame(width: 101, alignment: .leading)

            Spacer(minLength: 0)

            Image(systemName: "chevron.down")
                .font(.system(size: 8, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: 8, height: 4)
        }
        .padding(.leading, 12)
        .padding(.trailing, 4)
        .frame(width: 129, height: 31, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(BONColor.borderSubtle, lineWidth: 1)
                )
        )
    }
}

private struct AIChatMonthlySpendHeatmap: View {
    private let topRowsByColumn: [Int] = [
        5, 11, 12, 2, 3, 11, 2, 9, 5, 0,
        2, 1, 2, 6, 5, 1, 3, 3, 6, 1,
        2, 8, 5, 3, 7, 9, 13, 9, 2, 1
    ]

    var body: some View {
        GeometryReader { _ in
            let square: CGFloat = 8
            let step: CGFloat = 10
            let chartTop: CGFloat = 0
            let baseline = chartTop + 130
            let guideY = chartTop + 70

            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(BONColor.divider.opacity(0.65))
                    .frame(width: 310, height: 1)
                    .offset(y: guideY)

                Text("$10k")
                    .font(BONTypography.zalando(size: 8, weight: .regular))
                    .foregroundStyle(AIChatBudgetGraphicColor.caption)
                    .frame(width: 20, height: 10, alignment: .leading)
                    .offset(x: -6, y: chartTop)

                Text("$1k")
                    .font(BONTypography.zalando(size: 8, weight: .regular))
                    .foregroundStyle(AIChatBudgetGraphicColor.caption)
                    .frame(width: 18, height: 10, alignment: .leading)
                    .offset(x: -6, y: baseline - 5)

                ForEach(topRowsByColumn.indices, id: \.self) { column in
                    ForEach(visibleRows(fromTop: topRowsByColumn[column]), id: \.self) { row in
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(color(forRow: row))
                            .frame(width: square, height: square)
                            .offset(
                                x: 12 + CGFloat(column) * step,
                                y: CGFloat(row) * step
                            )
                    }
                }

                dateLabel("Apr 05")
                    .offset(x: 0, y: 144)

                dateLabel("Apr 20")
                    .offset(x: 138, y: 144)

                dateLabel("May 05")
                    .offset(x: 276, y: 144)
            }
        }
    }

    private func dateLabel(_ title: String) -> some View {
        Text(title)
            .font(BONTypography.zalando(size: 10, weight: .regular))
            .foregroundStyle(AIChatBudgetGraphicColor.caption)
            .frame(height: 12, alignment: .leading)
    }

    private func visibleRows(fromTop topRow: Int) -> [Int] {
        guard topRow <= 13 else {
            return []
        }

        return Array(topRow...13).filter { $0 != 4 }
    }

    private func color(forRow row: Int) -> Color {
        switch row {
        case 0:
            return AIChatBudgetGraphicColor.heatmapCrimson
        case 1:
            return AIChatBudgetGraphicColor.heatmapRed
        case 2:
            return AIChatBudgetGraphicColor.heatmapPink
        case 3:
            return AIChatBudgetGraphicColor.heatmapBlush
        case 5:
            return AIChatBudgetGraphicColor.heatmapPeach
        case 6:
            return AIChatBudgetGraphicColor.heatmapCream
        case 7:
            return AIChatBudgetGraphicColor.heatmapWarmCream
        case 8:
            return AIChatBudgetGraphicColor.heatmapPaleYellow
        case 9:
            return AIChatBudgetGraphicColor.heatmapLime100
        case 10:
            return AIChatBudgetGraphicColor.heatmapLime200
        case 11:
            return AIChatBudgetGraphicColor.heatmapLime300
        case 12:
            return AIChatBudgetGraphicColor.heatmapLime400Graph
        default:
            return AIChatBudgetGraphicColor.heatmapLime500
        }
    }
}

private struct AIChatMonthlySpendMetricStrip: View {
    var body: some View {
        HStack(spacing: 0) {
            AIChatMonthlySpendMetricCell(title: "AVG SPEND/DAY", value: "$204")
            AIChatMonthlySpendMetricCell(title: "MOST SPENT DAY", value: "14 Apr | $432")
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AIChatBudgetGraphicColor.panel)
        )
    }
}

private struct AIChatMonthlySpendMetricCell: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(BONTypography.zalando(size: 10, weight: .regular))
                .foregroundStyle(AIChatBudgetGraphicColor.caption)
                .frame(height: 12, alignment: .leading)

            Text(value)
                .font(BONTypography.zalando(size: 14, weight: .semibold))
                .foregroundStyle(BONColor.textPrimary)
                .frame(height: 17, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct AIChatBudgetCategoryRows: View {
    var body: some View {
        VStack(spacing: 0) {
            AIChatCategoryRow(icon: "fork.knife", title: "Dining", amount: "$353", trend: "↑ $112", trendColor: BONColor.error.opacity(0.70))
            AIChatDivider()
            AIChatCategoryRow(icon: "lightbulb", title: "Utilities", amount: "$120", trend: "-", trendColor: BONColor.textTertiary)
            AIChatDivider()
            AIChatCategoryRow(icon: "gamecontroller", title: "Entertainment", amount: "$90", trend: "↓ $28", trendColor: BONColor.success.opacity(0.80))
            AIChatDivider()
            AIChatCategoryRow(icon: "diamond", title: "Others", amount: "$45", trend: "↓ $65", trendColor: BONColor.textTertiary)
                .opacity(0.20)
        }
    }
}

private struct AIChatCategoryRow: View {
    let icon: String
    let title: String
    let amount: String
    let trend: String
    let trendColor: Color

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .light))
                .frame(width: 24)

            Text(title)
                .font(BONTypography.zalando(size: 16, weight: .medium))

            Spacer()

            Text(amount)
                .font(BONTypography.zalando(size: 16, weight: .bold))

            Text(trend)
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(trendColor)
                .frame(width: 52, alignment: .trailing)
        }
        .frame(height: 56)
    }
}

private struct AIChatBudgetTimelineChart: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let baselineY = proxy.size.height * 0.56

            ZStack(alignment: .topLeading) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: baselineY))
                    path.addCurve(
                        to: CGPoint(x: width, y: baselineY - 20),
                        control1: CGPoint(x: width * 0.28, y: baselineY - 36),
                        control2: CGPoint(x: width * 0.62, y: baselineY + 18)
                    )
                }
                .stroke(BONColor.accentLime, style: StrokeStyle(lineWidth: 4, lineCap: .round))

                ForEach([
                    ("Rent\n$1,400", 0.08, baselineY - 48),
                    ("Today", 0.50, baselineY - 18),
                    ("Paycheck\n$2,500", 0.78, baselineY - 62),
                    ("May 31", 0.94, baselineY - 28)
                ], id: \.0) { label, xFactor, y in
                    VStack(spacing: 6) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 8, height: 8)
                        Text(label)
                            .font(BONTypography.zalando(size: 10, weight: .regular))
                            .foregroundStyle(BONColor.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .position(x: width * xFactor, y: y)
                }
            }
        }
    }
}

private struct AIChatIncomeBars: View {
    private let values: [(String, CGFloat, String)] = [
        ("Week 1", 0.66, "$800"),
        ("Week 2", 0.34, "$400"),
        ("Week 3", 1.0, "$1200"),
        ("Week 4", 0.54, "$650")
    ]

    var body: some View {
        HStack(alignment: .bottom, spacing: 18) {
            ForEach(values, id: \.0) { label, height, amount in
                VStack(spacing: 8) {
                    Text(amount)
                        .font(BONTypography.zalando(size: 11, weight: .medium))
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [BONColor.accentLime, Color(red: 0.83, green: 1.0, blue: 0.48)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 42, height: 90 * height)
                    Text(label)
                        .font(BONTypography.zalando(size: 10, weight: .regular))
                        .foregroundStyle(BONColor.textTertiary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct AIChatRunwayTimeline: View {
    private let events: [(String, String, CGFloat, Color)] = [
        ("Rent", "$1,400", 0.08, BONColor.error.opacity(0.75)),
        ("Utilities", "$185", 0.24, BONColor.warning.opacity(0.76)),
        ("Chase min.", "$185", 0.40, BONColor.warning.opacity(0.76)),
        ("Paycheck", "$650", 0.58, BONColor.accentLime),
        ("Discover", "$48", 0.76, BONColor.warning.opacity(0.76)),
        ("Paycheck", "$650", 0.94, BONColor.accentLime)
    ]

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let lineX = width * 0.12

            ZStack(alignment: .topLeading) {
                Capsule(style: .continuous)
                    .fill(BONColor.divider)
                    .frame(width: 4, height: proxy.size.height - 10)
                    .position(x: lineX, y: proxy.size.height / 2)

                ForEach(events, id: \.0) { title, amount, yFactor, color in
                    HStack(spacing: 14) {
                        Circle()
                            .fill(color)
                            .frame(width: 14, height: 14)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(title)
                                .font(BONTypography.zalando(size: 14, weight: .medium))
                            Text(amount)
                                .chatCaption()
                        }

                        Spacer()
                    }
                    .position(x: width / 2 + 10, y: proxy.size.height * yFactor)
                }
            }
        }
    }
}

private struct AIChatAccountRow: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let trailing: String
    let footnote: String

    static let debtRows: [AIChatAccountRow] = [
        .init(icon: "creditcard", title: "Chase Sapphire X2581", subtitle: "91% utilization", trailing: "$8,432", footnote: "$185 min"),
        .init(icon: "creditcard", title: "Discover It X9821", subtitle: "91% utilization", trailing: "$1,247", footnote: "$48 min"),
        .init(icon: "creditcard", title: "Amex Blue Cash", subtitle: "91% utilization", trailing: "$214", footnote: "$48 min")
    ]
}

private struct AIChatAccountRows: View {
    let rows: [AIChatAccountRow]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                HStack(spacing: 12) {
                    Image(systemName: row.icon)
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(BONColor.textPrimary)
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(row.title)
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                            .foregroundStyle(BONColor.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                        Text(row.subtitle)
                            .chatCaption()
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 5) {
                        Text(row.trailing)
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                            .foregroundStyle(BONColor.textPrimary)
                        Text(row.footnote)
                            .chatCaption()
                    }
                }
                .frame(height: 62)

                if row.id != rows.last?.id {
                    AIChatDivider()
                }
            }
        }
    }
}

private struct AIChatSmallMetric: View {
    let title: String
    let value: String
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 5) {
            Text(title)
                .chatCaption()
            Text(value)
                .font(BONTypography.zalando(size: 14, weight: .semibold))
                .foregroundStyle(BONColor.textPrimary)
        }
    }
}

private struct AIChatProgressLine: View {
    let title: String
    let value: String
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .chatCaption()
                Spacer()
                Text(value)
                    .chatCaption()
            }

            GeometryReader { proxy in
                Capsule(style: .continuous)
                    .fill(BONColor.divider)
                    .overlay(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(BONColor.accentLime)
                            .frame(width: proxy.size.width * min(1, max(0, progress)))
                    }
            }
            .frame(height: 8)
        }
    }
}

private enum AIChatViewAllDirection {
    case down
    case up

    var systemImage: String {
        switch self {
        case .down:
            return "chevron.down"
        case .up:
            return "chevron.up"
        }
    }
}

private struct AIChatViewAllButton: View {
    var direction: AIChatViewAllDirection = .down
    var hasShadow = false

    var body: some View {
        Button {
            BONHaptics.selection()
        } label: {
            HStack(spacing: 8) {
                Text("view all")
                    .font(BONTypography.zalando(size: 14, weight: .light))
                Image(systemName: direction.systemImage)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(BONColor.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: 33)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(BONColor.borderSubtle, lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(hasShadow ? 0.08 : 0), radius: 4, x: 0, y: 4)
        }
        .buttonStyle(BONScaleButtonStyle())
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel("View all")
    }
}

private struct AIChatDivider: View {
    var body: some View {
        Rectangle()
            .fill(BONColor.divider)
            .frame(height: 1)
    }
}

private extension View {
    func chatBodyText() -> some View {
        self
            .font(BONTypography.zalando(size: 16, weight: .regular))
            .foregroundStyle(BONColor.textPrimary)
            .lineSpacing(3)
    }

    func chatCaption() -> some View {
        self
            .font(BONTypography.zalando(size: 12, weight: .regular))
            .foregroundStyle(BONColor.textTertiary)
    }

    func chatCardTitle() -> some View {
        self
            .font(BONTypography.zalando(size: 16, weight: .medium))
            .foregroundStyle(BONColor.textPrimary)
    }
}

#Preview {
    AIChatView()
}
