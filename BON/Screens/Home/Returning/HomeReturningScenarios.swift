import SwiftUI

// MARK: - Scenario Definition
//
// Home — Returning scenarios. Figma file `O2 Final`, section `61:2687`.
// Frames (390 × 845 unless noted):
//   • 61:2688 Home - Credit score             (390 × 1305, scrollable)
//   • 61:2860 Home - Paycheck arrived_budget already created
//   • 61:2975 Home - Paycheck arrived_budget not created
//   • 61:3090 Home - New transactions_budget already created
//   • 61:3226 Home - Payment due
//   • 61:3326 Home - Statement landed
//   • 61:3490 Home - Due date near
//
// This file is intentionally self-contained: it does not modify
// `HomeFirstTimerClickedView`, the design system, navigation, or any
// existing components. Wiring into AppRouter happens in a separate pass
// once the visual review on these scenarios is approved.

enum HomeReturningScenario: String, CaseIterable, Identifiable {
    case creditScore
    case paycheckBudgetCreated
    case paycheckNoBudget
    case newTransactions
    case paymentDue
    case statementLanded
    case dueDateNear

    var id: String { rawValue }

    var launchKey: String {
        switch self {
        case .creditScore:           return "credit-score"
        case .paycheckBudgetCreated: return "paycheck-budgeted"
        case .paycheckNoBudget:      return "paycheck-no-budget"
        case .newTransactions:       return "new-transactions"
        case .paymentDue:            return "payment-due"
        case .statementLanded:       return "statement-landed"
        case .dueDateNear:           return "due-date-near"
        }
    }

    var displayName: String {
        switch self {
        case .creditScore:           return "Credit score"
        case .paycheckBudgetCreated: return "Paycheck — budget created"
        case .paycheckNoBudget:      return "Paycheck — no budget"
        case .newTransactions:       return "New transactions"
        case .paymentDue:            return "Payment due"
        case .statementLanded:       return "Statement landed"
        case .dueDateNear:           return "Due date near"
        }
    }

    /// `true` if the screen's natural Figma height exceeds 845 and the
    /// content scrolls (only the credit-score scenario today).
    var scrolls: Bool {
        self == .creditScore
    }

    /// Parsed from the launch argument `-BONHomeReturningScenario <key>` so
    /// the user can boot the simulator straight into a chosen scenario
    /// without us wiring AppRouter yet.
    static func fromLaunchArguments() -> HomeReturningScenario? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-BONHomeReturningScenario"),
              arguments.indices.contains(index + 1) else {
            return nil
        }

        let value = arguments[index + 1].lowercased()
        return HomeReturningScenario.allCases.first { $0.launchKey == value }
    }
}

// MARK: - Layout Metrics

struct HomeReturningMetrics {
    let size: CGSize
    let safeArea: EdgeInsets

    let baselineWidth: CGFloat = 390

    var screenWidth: CGFloat { size.width }
    var screenHeight: CGFloat { size.height }
    var safeTop: CGFloat { max(safeArea.top, 54) }
    var safeBottom: CGFloat { max(safeArea.bottom, 34) }
    /// 24pt content margin (matches first-timer + spec)
    var horizontalMargin: CGFloat { 24 }
    var contentWidth: CGFloat { max(310, screenWidth - (horizontalMargin * 2)) }
    /// The hero panel uses an 8pt margin so it fills more of the device,
    /// matching the responsive policy used by the first-timer surface.
    var panelHorizontalMargin: CGFloat { 8 }
    var panelWidth: CGFloat { screenWidth - (panelHorizontalMargin * 2) }
    var navBottom: CGFloat { safeBottom + 14 }
}

// MARK: - Host View

struct HomeReturningView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let scenario: HomeReturningScenario
    var onSelectScenario: ((HomeReturningScenario) -> Void)? = nil
    var onTalkWithAI: () -> Void = {}
    var onPrimaryAction: () -> Void = {}

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeReturningMetrics(
                size: proxy.size,
                safeArea: proxy.safeAreaInsets
            )

            ZStack {
                BONColor.backgroundPrimary
                    .ignoresSafeArea()

                content(metrics: metrics)

                BONBottomNav(
                    selectedID: "home",
                    items: HomeReturningNavFixture.items,
                    width: metrics.contentWidth
                )
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, metrics.navBottom)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func content(metrics: HomeReturningMetrics) -> some View {
        if scenario.scrolls {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: metrics.safeTop - 6)

                    HomeReturningHeroPanel(metrics: metrics) {
                        scenarioHeroContent(metrics: metrics)
                    }
                    .padding(.horizontal, metrics.panelHorizontalMargin)

                    HomeReturningTasksProgressRow()
                        .padding(.top, 24)
                        .padding(.horizontal, metrics.horizontalMargin)

                    HomeReturningMoreActionsBlock(metrics: metrics)
                        .padding(.top, 32)
                        .padding(.horizontal, metrics.horizontalMargin)

                    HomeReturningSecurityCard(width: metrics.contentWidth)
                        .padding(.top, 48)

                    Color.clear.frame(height: metrics.navBottom + 96)
                }
                .frame(width: metrics.screenWidth)
            }
        } else {
            VStack(spacing: 0) {
                Color.clear.frame(height: metrics.safeTop - 6)

                HomeReturningHeroPanel(metrics: metrics) {
                    scenarioHeroContent(metrics: metrics)
                }
                .padding(.horizontal, metrics.panelHorizontalMargin)

                HomeReturningTasksProgressRow()
                    .padding(.top, 24)
                    .padding(.horizontal, metrics.horizontalMargin)

                Spacer(minLength: 0)
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        }
    }

    @ViewBuilder
    private func scenarioHeroContent(metrics: HomeReturningMetrics) -> some View {
        switch scenario {
        case .creditScore:
            HomeReturningCreditScoreHero(onTalkWithAI: onTalkWithAI)
        case .paycheckBudgetCreated:
            HomeReturningPaycheckHero(
                primaryCTA: .talkWithAI,
                onCTA: onTalkWithAI
            )
        case .paycheckNoBudget:
            HomeReturningPaycheckHero(
                primaryCTA: .createBudget,
                onCTA: onPrimaryAction
            )
        case .newTransactions:
            HomeReturningTransactionsHero(onTalkWithAI: onTalkWithAI)
        case .paymentDue:
            HomeReturningPaymentDueHero(onSetUpAutoPay: onPrimaryAction)
        case .statementLanded:
            HomeReturningStatementHero(onAskAI: onTalkWithAI)
        case .dueDateNear:
            HomeReturningDueDateHero(onTalkWithAI: onTalkWithAI)
        }
    }
}

// MARK: - Hero Panel Chassis
//
// Shared white rounded panel with the lime inset glow.
// 56pt continuous corner radius, white fill, `inset 0 0 12 rgba(219,255,111,0.8)`.
// Content layout: 20 top padding, 24 horizontal, 32 bottom; top chrome row
// (40pt buttons + 110×40 AI mode pill); body content; CTA pill; all with
// `32pt` gaps between them.

struct HomeReturningHeroPanel<Content: View>: View {
    let metrics: HomeReturningMetrics
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 32) {
            HomeReturningTopChromeRow()

            content()
        }
        .padding(.top, 20)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .fill(Color.white)
        }
        .overlay {
            // The Figma token is `inset 0 0 12 rgba(219,255,111,0.8)`.
            // SwiftUI doesn't have first-class inset shadows, so we emulate
            // it with a soft inner stroke that bleeds into the corner curve.
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .strokeBorder(BONColor.lime200.opacity(0.80), lineWidth: 6)
                .blur(radius: 8)
                .padding(0.5)
                .allowsHitTesting(false)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 56, style: .continuous)
                .stroke(BONColor.lime100.opacity(0.42), lineWidth: 1)
                .allowsHitTesting(false)
        }
        .compositingGroup()
        .shadow(color: BONColor.lime100.opacity(0.28), radius: 18, x: 0, y: 0)
    }
}

private struct HomeReturningTopChromeRow: View {
    var body: some View {
        HStack(spacing: 0) {
            HomeReturningGlassIcon(asset: "topProfile", label: "Profile") { }

            Spacer(minLength: 8)

            HomeReturningAIModePill()

            Spacer(minLength: 8)

            HomeReturningGlassIcon(asset: "topBell", label: "Notifications") { }
        }
        .frame(height: 40)
    }
}

private struct HomeReturningGlassIcon: View {
    let asset: String
    let label: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .overlay(Circle().stroke(Color.black.opacity(0.04), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.08), radius: 32, x: 0, y: 8)

                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.black.opacity(0.88))
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(label)
    }
}

private struct HomeReturningAIModePill: View {
    var body: some View {
        Text("AI mode")
            .font(BONTypography.zalando(size: 12, weight: .regular))
            .foregroundStyle(Color(red: 0.20, green: 0.20, blue: 0.20).opacity(0.64))
            .tracking(-0.12)
            .frame(width: 110, height: 40)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.48), lineWidth: 1)
                    )
            )
            .accessibilityLabel("AI mode")
    }
}

// MARK: - Inline CTA Pill
//
// All returning scenarios share the same dark glass capsule CTA, but with
// different copy + tap targets. Spec: rgba(0,0,0,0.88) fill, 100pt radius,
// `0 8 32 rgba(0,0,0,0.12)` outer shadow, `inset 0 0 8 rgba(255,255,255,0.4)`
// soft inner highlight, padding 20/8.

struct HomeReturningCTAPill: View {
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
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(.white)
                .tracking(-0.14)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .frame(minHeight: 33)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.black.opacity(0.88))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.40), lineWidth: 1)
                        .blur(radius: 3)
                        .padding(0.5)
                        .allowsHitTesting(false)
                )
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Scenario 1: Credit score

struct HomeReturningCreditScoreHero: View {
    var onTalkWithAI: () -> Void = {}

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 0) {
                CreditScoreGauge()
                    .frame(width: 326, height: 167)
                    .padding(.bottom, -78) // gauge overshoots, score sits inside the arc

                VStack(spacing: 2) {
                    Text("614")
                        .font(BONTypography.geistPixel(size: 48))
                        .tracking(-3.84)
                        .foregroundStyle(Color.black)
                        .frame(height: 62)

                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(BONColor.lime700)

                        Text("38 points")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .tracking(-0.12)
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    .frame(height: 15)
                }
            }
            .padding(.top, -68) // gauge is anchored above the card top edge in Figma

            Text("Hey Abhinav, Your score went up 38 pts, know what caused this.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(width: 264)
                .padding(.horizontal, 8)

            HomeReturningCTAPill(title: "Talk with AI", action: onTalkWithAI)
        }
    }
}

private struct CreditScoreGauge: View {
    var body: some View {
        ZStack {
            // Outer soft glow ring
            Circle()
                .trim(from: 0.54, to: 0.96)
                .stroke(BONColor.lime50, style: StrokeStyle(lineWidth: 48, lineCap: .butt))
                .rotationEffect(.degrees(8))
                .blur(radius: 4)

            // Main gauge: angular gradient lime, top arc only
            Circle()
                .trim(from: 0.54, to: 0.90)
                .stroke(
                    AngularGradient(
                        stops: [
                            .init(color: BONColor.lime500, location: 0.55),
                            .init(color: BONColor.lime300, location: 0.72),
                            .init(color: BONColor.lime100, location: 0.92)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 48, lineCap: .butt)
                )
                .rotationEffect(.degrees(8))
                .shadow(color: BONColor.lime500.opacity(0.32), radius: 12, x: 0, y: 0)

            // Indicator needle near the right edge of the arc
            Rectangle()
                .fill(Color(red: 0.12, green: 0.18, blue: 0.04))
                .frame(width: 1.6, height: 56)
                .rotationEffect(.degrees(38))
                .offset(x: 92, y: -22)
        }
        .frame(width: 326, height: 167, alignment: .top)
        .mask {
            // Crop the bottom half so the score "sinks into" the arc
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 110, alignment: .top)
        }
    }
}

// MARK: - Scenarios 2 & 3: Paycheck arrived (with / without budget)

struct HomeReturningPaycheckHero: View {
    enum PrimaryCTA {
        case talkWithAI
        case createBudget

        var title: String {
            switch self {
            case .talkWithAI:   return "Talk with AI"
            case .createBudget: return "Create a budget"
            }
        }
    }

    let primaryCTA: PrimaryCTA
    var onCTA: () -> Void = {}

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Text("Pay check arrivedddddd 🎉.")
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)

                VStack(spacing: 4) {
                    Text("new total balance: $3,254")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(Color.black.opacity(0.50))
                        .tracking(-0.12)

                    Text("$2,800")
                        .font(BONTypography.geistPixel(size: 56))
                        .tracking(-1.12)
                        .foregroundStyle(.black)
                        .frame(height: 64)
                }
            }

            FixSpendCard()
                .padding(.top, 4)

            HomeReturningCTAPill(title: primaryCTA.title, action: onCTA)
                .padding(.top, 4)
        }
    }
}

private struct FixSpendCard: View {
    private let rows: [(String, String)] = [
        ("Rent", "$1,400"),
        ("Bills", "$245"),
        ("Subscriptions", "$97"),
        ("Cards minimums", "$545")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fix spend this month")
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.5))
                .padding(.leading, 4)
                .padding(.top, 2)

            VStack(spacing: 12) {
                ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                    HStack {
                        Text(row.0)
                            .font(BONTypography.zalando(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                        Spacer()
                        Text(row.1)
                            .font(BONTypography.zalando(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(red: 0.96, green: 0.96, blue: 0.96), lineWidth: 1)
        )
    }
}

// MARK: - Scenario 4: New transactions

struct HomeReturningTransactionsHero: View {
    var onTalkWithAI: () -> Void = {}

    private let txns: [TransactionRow] = [
        .init(merchant: "Amazon fresh", account: "Chase Sapphire X2543", amount: "$353", date: "02 Feb"),
        .init(merchant: "Doordash", account: "Discover it X4532", amount: "$289", date: "03 Feb")
    ]

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                Text("transactions total")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.50))
                    .tracking(-0.12)

                Text("$1,054")
                    .font(BONTypography.geistPixel(size: 56))
                    .tracking(-1.12)
                    .foregroundStyle(.black)
                    .frame(height: 64)
                    .padding(.top, 2)
            }

            VStack(spacing: 12) {
                ForEach(Array(txns.enumerated()), id: \.offset) { index, txn in
                    TransactionRowView(row: txn)

                    if index < txns.count - 1 {
                        Rectangle()
                            .fill(BONColor.divider)
                            .frame(height: 1)
                            .padding(.horizontal, 4)
                    }
                }

                Button {
                    BONHaptics.selection()
                } label: {
                    Text("+ 5 more")
                        .font(BONTypography.zalando(size: 14, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.5))
                        .tracking(-0.14)
                        .padding(.top, 4)
                }
                .buttonStyle(BONScaleButtonStyle())
                .accessibilityLabel("Show 5 more transactions")
            }
            .padding(.horizontal, 4)

            (Text("I want to flag the Doordash transaction.\n")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundColor(.black) +
             Text("Food delivery is up $42 this month.")
                .font(BONTypography.zalando(size: 16, weight: .semibold))
                .foregroundColor(.black))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 8)

            HomeReturningCTAPill(title: "Talk with AI", action: onTalkWithAI)
        }
    }
}

private struct TransactionRow {
    let merchant: String
    let account: String
    let amount: String
    let date: String
}

private struct TransactionRowView: View {
    let row: TransactionRow

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(BONColor.borderSubtle, lineWidth: 1)
                Image(systemName: "creditcard")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.72))
            }
            .frame(width: 36, height: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(row.merchant)
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                Text(row.account)
                    .font(BONTypography.zalando(size: 13, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(row.amount)
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                Text(row.date)
                    .font(BONTypography.zalando(size: 13, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .lineLimit(1)
            }
        }
        .frame(height: 44)
    }
}

// MARK: - Scenario 5: Payment due

struct HomeReturningPaymentDueHero: View {
    var onSetUpAutoPay: () -> Void = {}

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 0) {
                Text("due in 5 days")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.50))
                    .tracking(-0.12)

                Text("$185")
                    .font(BONTypography.geistPixel(size: 56))
                    .tracking(-1.12)
                    .foregroundStyle(.black)
                    .frame(height: 64)
            }

            DiscoverStudentCard()

            Text("Auto-pay isn't on yet.\nWant me to set it up?")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            HomeReturningCTAPill(title: "Set up now", action: onSetUpAutoPay)
        }
    }
}

private struct DiscoverStudentCard: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Multi-stop horizontal gradient approximating the Figma artwork:
            // dark maroon → orange → magenta → blue
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.18, green: 0.06, blue: 0.04), location: 0.00),
                            .init(color: Color(red: 0.60, green: 0.24, blue: 0.10), location: 0.18),
                            .init(color: Color(red: 0.78, green: 0.36, blue: 0.18), location: 0.32),
                            .init(color: Color(red: 0.66, green: 0.22, blue: 0.30), location: 0.50),
                            .init(color: Color(red: 0.38, green: 0.20, blue: 0.46), location: 0.66),
                            .init(color: Color(red: 0.20, green: 0.30, blue: 0.60), location: 0.84),
                            .init(color: Color(red: 0.30, green: 0.42, blue: 0.68), location: 1.00)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    // Subtle diagonal sheen
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.10),
                                    Color.clear,
                                    Color.white.opacity(0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.softLight)
                )
                .frame(height: 200)
                .shadow(color: Color.black.opacity(0.18), radius: 16, x: 0, y: 10)

            // Card chrome
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DISCOVER STUDENT")
                            .font(BONTypography.zalando(size: 12, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(.white)

                        Text("XXXX  XXXX  4778")
                            .font(BONTypography.zalando(size: 14, weight: .light))
                            .tracking(1.4)
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        Text("DISC")
                            .font(BONTypography.zalando(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                        Circle()
                            .fill(Color(red: 1.0, green: 0.50, blue: 0.0))
                            .frame(width: 8, height: 8)
                            .offset(y: -1)
                        Text("VER")
                            .font(BONTypography.zalando(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Spacer()

                // EMV chip
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.78, green: 0.66, blue: 0.36),
                                    Color(red: 0.62, green: 0.50, blue: 0.20)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 28, height: 22)

                    VStack(spacing: 1) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.25))
                                .frame(height: 1)
                        }
                    }
                    .padding(.horizontal, 4)
                    .frame(width: 28, height: 22)
                }

                Spacer()

                HStack {
                    Text("PETER PARKER")
                        .font(BONTypography.zalando(size: 12, weight: .semibold))
                        .tracking(0.6)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("DISCOVER")
                        .font(BONTypography.zalando(size: 11, weight: .bold))
                        .tracking(1.2)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(height: 200)
        }
        .overlay(
            // Floating late-fee pill
            Text("Late fee charges: $40")
                .font(BONTypography.zalando(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.20), radius: 8, x: 0, y: 4)
                )
        )
    }
}

// MARK: - Scenario 6: Statement landed

struct HomeReturningStatementHero: View {
    var onAskAI: () -> Void = {}

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(BONColor.error)

                    Text("$240 vs April")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(BONColor.error)
                }

                Text("$2,482")
                    .font(BONTypography.geistPixel(size: 56))
                    .tracking(-1.12)
                    .foregroundStyle(.black)
                    .frame(height: 64)
            }

            StatementBarChart()
                .frame(height: 160)

            Text("Spent in May.\nDining is where it crept up.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            HomeReturningCTAPill(title: "Get detailed breakdown with AI", action: onAskAI)
        }
    }
}

private struct StatementBarChart: View {
    private struct Bar: Identifiable {
        let id = UUID()
        let value: CGFloat       // 0...1 normalised to chart height
        let color: Color
        let icon: String         // SF Symbol approximation
    }

    private var bars: [Bar] {
        [
            Bar(value: 0.76, color: Color(red: 0.55, green: 0.78, blue: 0.92), icon: "fork.knife"),
            Bar(value: 0.98, color: Color(red: 0.95, green: 0.60, blue: 0.30), icon: "bag.fill"),
            Bar(value: 0.50, color: Color(red: 0.40, green: 0.52, blue: 0.86), icon: "gamecontroller.fill"),
            Bar(value: 0.86, color: Color(red: 0.70, green: 0.86, blue: 0.32), icon: "lightbulb.fill"),
            Bar(value: 0.18, color: Color(red: 0.78, green: 0.74, blue: 0.18), icon: "diamond.fill")
        ]
    }

    private let yLabels = ["$1000", "$500", "$200", "$0"]

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Y-axis labels
            VStack(alignment: .trailing) {
                ForEach(yLabels, id: \.self) { label in
                    Text(label)
                        .font(BONTypography.zalando(size: 10, weight: .regular))
                        .foregroundStyle(Color(red: 0.27, green: 0.27, blue: 0.27))
                        .frame(height: 14)
                    if label != yLabels.last { Spacer(minLength: 0) }
                }
            }
            .frame(width: 36, height: 130, alignment: .top)

            // Chart area
            GeometryReader { proxy in
                let chartHeight: CGFloat = 130
                let columnWidth = (proxy.size.width - CGFloat(bars.count - 1) * 16) / CGFloat(bars.count)
                let barWidth: CGFloat = min(28, columnWidth)

                ZStack(alignment: .topLeading) {
                    // Horizontal grid lines (4 evenly spaced)
                    VStack(spacing: 0) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .fill(BONColor.divider)
                                .frame(height: 1)
                            if true { Spacer(minLength: 0) }
                        }
                    }
                    .frame(height: chartHeight)

                    // Bars + icons under each bar
                    HStack(alignment: .bottom, spacing: 16) {
                        ForEach(Array(bars.enumerated()), id: \.element.id) { _, bar in
                            VStack(spacing: 6) {
                                Spacer(minLength: 0)
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(bar.color)
                                    .frame(width: barWidth, height: max(8, bar.value * chartHeight))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: chartHeight, alignment: .bottom)
                }

                // X-axis icon row
                HStack(spacing: 16) {
                    ForEach(Array(bars.enumerated()), id: \.element.id) { _, bar in
                        Image(systemName: bar.icon)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.72))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 22)
                .offset(y: chartHeight + 6)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Scenario 7: Due date near

struct HomeReturningDueDateHero: View {
    var onTalkWithAI: () -> Void = {}

    var body: some View {
        VStack(spacing: 22) {
            VStack(spacing: 2) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(BONColor.error)
                        .frame(width: 6, height: 6)

                    Text("Tomorrow")
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .foregroundStyle(BONColor.error)
                }

                Text("$48")
                    .font(BONTypography.geistPixel(size: 56))
                    .tracking(-1.12)
                    .foregroundStyle(.black)
                    .frame(height: 64)
            }

            DueCardRow()

            Text("Pay now, ")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(.black)
                + Text("skip a $39 late fee.")
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundColor(BONColor.error)
                + Text("\nYou have it in checking.")
                    .font(BONTypography.zalando(size: 16, weight: .regular))
                    .foregroundColor(.black)

            HomeReturningCTAPill(title: "Talk with AI", action: onTalkWithAI)
        }
    }
}

private struct DueCardRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(BONColor.borderSubtle, lineWidth: 1))

                // Chase Sapphire octagon mark — drawn as a 4-pointed star to
                // evoke the brand mark without bundling the actual logo.
                Image(systemName: "diamond.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 0.07, green: 0.34, blue: 0.65))
            }
            .frame(width: 36, height: 36)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Chase Sapphire")
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                Text("XX 2345")
                    .font(BONTypography.zalando(size: 13, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.5))
            }

            Spacer()

            Button {
                BONHaptics.impact(.light)
            } label: {
                Text("Pay now")
                    .font(BONTypography.zalando(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(BONColor.accentLime)
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(Color.black.opacity(0.85), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel("Pay now")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0.94, green: 0.94, blue: 0.94), lineWidth: 1)
        )
    }
}

// MARK: - Tasks + Progress Cards Row
//
// Visible below the hero panel on every returning scenario.
// Spec: two 163×120 white cards, 16pt radius, `#F7F7F7` border, with a 16pt
// gap between them — total 342pt, matching 24pt page margins on a 390pt
// baseline frame.

struct HomeReturningTasksProgressRow: View {
    var body: some View {
        HStack(spacing: 16) {
            TasksCard()
            ProgressCard()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct TasksCard: View {
    var body: some View {
        ZStack(alignment: .top) {
            cardChassis

            Text("Tasks")
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.9))
                .padding(.top, 18)

            // Rotated mini-card with pending count
            MiniPendingCard()
                .rotationEffect(.degrees(-8.79))
                .offset(y: 56)
                .accessibilityHidden(true)
        }
        .frame(width: 163, height: 120)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tasks. 5 pending.")
    }

    private var cardChassis: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: 0.97, green: 0.97, blue: 0.97), lineWidth: 1)
            )
    }
}

private struct MiniPendingCard: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("5")
                .font(BONTypography.geistPixel(size: 24))
                .tracking(-0.48)
                .foregroundStyle(.black)

            Text("pending")
                .font(.system(size: 10, weight: .regular, design: .serif).italic())
                .foregroundStyle(Color(red: 0.47, green: 0.47, blue: 0.47))

            VStack(spacing: 4) {
                Capsule()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 60, height: 4)
                Capsule()
                    .fill(Color.white.opacity(0.72))
                    .frame(width: 90, height: 4)
            }
            .padding(.top, 6)
        }
        .frame(width: 130, height: 80)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.76, green: 0.92, blue: 0.99), location: 0.31),
                            .init(color: Color.white, location: 0.92)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 1)
                )
        )
    }
}

private struct ProgressCard: View {
    var body: some View {
        ZStack {
            // Card chassis
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0.97, green: 0.97, blue: 0.97), lineWidth: 1)
                )

            // Title
            VStack(spacing: 0) {
                Text("Progress")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.9))
                    .padding(.top, 18)

                Spacer()
            }

            // Green wave + amount
            ProgressWaveBackground()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(spacing: -4) {
                Spacer()
                Text("saved till now")
                    .font(.system(size: 10, weight: .regular, design: .serif).italic())
                    .foregroundStyle(Color(red: 0.47, green: 0.47, blue: 0.47))

                Text("$285")
                    .font(BONTypography.geistPixel(size: 40))
                    .tracking(-0.80)
                    .foregroundStyle(.black)
                    .padding(.bottom, 8)
            }
        }
        .frame(width: 163, height: 120)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress. $285 saved till now.")
    }
}

private struct ProgressWaveBackground: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            // Wave shape filled with soft lime
            WaveShape()
                .fill(
                    LinearGradient(
                        colors: [
                            BONColor.lime100.opacity(0.42),
                            BONColor.lime200.opacity(0.92)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 92)

            // Decorative dot cluster (top-right) approximating Figma ellipses
            ZStack {
                ForEach(0..<14, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: 3, height: 3)
                        .offset(
                            x: CGFloat(40 + ((i * 53) % 35) - 15),
                            y: CGFloat(-50 + (i * 5) % 30)
                        )
                }
            }
            .frame(width: 60, height: 60)
            .offset(x: 50, y: -32)
            .allowsHitTesting(false)
        }
    }
}

private struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let bottomY = rect.height
        let baselineY = rect.height * 0.32

        path.move(to: CGPoint(x: 0, y: bottomY))
        path.addLine(to: CGPoint(x: 0, y: baselineY))

        // Smooth wave across the card
        path.addCurve(
            to: CGPoint(x: rect.width, y: baselineY - 14),
            control1: CGPoint(x: rect.width * 0.35, y: baselineY - 32),
            control2: CGPoint(x: rect.width * 0.62, y: baselineY + 14)
        )

        path.addLine(to: CGPoint(x: rect.width, y: bottomY))
        path.closeSubpath()
        return path
    }
}

// MARK: - "More actions" Block (Credit-score scenario only, when scrolled)

private struct HomeReturningMoreActionsBlock: View {
    let metrics: HomeReturningMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("More actions")
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(.black)

            HStack(alignment: .top) {
                ReturningShortcut(asset: "homeActionActiveCards", title: "Active cards")
                Spacer()
                ReturningShortcut(asset: "homeActionGetCash", title: "Get Cash")
                Spacer()
                ReturningShortcut(asset: "homeActionReferEarn", title: "Refer & earn")
            }
            .padding(.top, 20)

            HStack(alignment: .top, spacing: 0) {
                ReturningShortcut(asset: "homeActionCreditScore", title: "Credit score")
                    .frame(width: 79)

                Spacer(minLength: 0)

                ReturningBudgetingPromoCard(width: metrics.contentWidth - 121)
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ReturningShortcut: View {
    let asset: String
    let title: String

    var body: some View {
        Button {
            BONHaptics.selection()
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white, Color(red: 0.97, green: 0.97, blue: 0.97)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(BONColor.borderSubtle, lineWidth: 1))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 8)

                    Image(asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                        .frame(width: 20, height: 20)
                }
                .frame(width: 64, height: 64)

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
}

private struct ReturningBudgetingPromoCard: View {
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image("homeActionBudgetingArtwork")
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .frame(width: 192, height: 87)
                .clipped()
                .position(x: -4, y: 51.5)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.97, green: 0.97, blue: 0.97)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 16, height: 105)
                .blur(radius: 4)
                .position(x: 94, y: 45)

            VStack(alignment: .leading, spacing: 8) {
                Text("Do free budgeting")
                    .font(BONTypography.zalando(size: 12, weight: .medium))
                    .foregroundStyle(.black)

                Text("Start now")
                    .font(BONTypography.zalando(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 77, height: 25)
                    .background(Capsule(style: .continuous).fill(.black))
            }
            .frame(width: 112, height: 47, alignment: .leading)
            .position(x: width - 56, y: 45)
        }
        .frame(width: width, height: 90)
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(BONColor.borderSubtle, lineWidth: 1)
                )
        )
    }
}

// MARK: - Security Card (credit-score scrolling tail)

private struct HomeReturningSecurityCard: View {
    let width: CGFloat

    var body: some View {
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
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(.white.opacity(0.46))
            }
            .frame(width: 112, height: 112)

            VStack(alignment: .leading, spacing: 8) {
                Text("100% secure and\nprivate")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(.black)
                    .lineSpacing(1)
                Text("We never sell or share\nyour data.")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(.black)
            }
            .padding(.leading, 24)

            Spacer(minLength: 0)
        }
        .frame(width: width, height: 112)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.56),
                    Color(red: 0.93, green: 0.93, blue: 0.93)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            Rectangle().stroke(BONColor.borderSubtle, lineWidth: 1)
        )
    }
}

// MARK: - Nav Fixture

private enum HomeReturningNavFixture {
    static let items: [BONBottomNavItem] = [
        BONBottomNavItem(id: "cards",  title: "Cards",  imageAsset: "navCards"),
        BONBottomNavItem(id: "spend",  title: "Spend",  imageAsset: "navSpend"),
        BONBottomNavItem(id: "home",   title: "Home",   imageAsset: "navHome"),
        BONBottomNavItem(id: "credit", title: "Credit", imageAsset: "navCredit"),
        BONBottomNavItem(id: "money",  title: "Money",  imageAsset: "navMoney")
    ]
}

// MARK: - Previews

#Preview("Credit score") {
    HomeReturningView(scenario: .creditScore)
}

#Preview("Paycheck — budgeted") {
    HomeReturningView(scenario: .paycheckBudgetCreated)
}

#Preview("Paycheck — no budget") {
    HomeReturningView(scenario: .paycheckNoBudget)
}

#Preview("New transactions") {
    HomeReturningView(scenario: .newTransactions)
}

#Preview("Payment due") {
    HomeReturningView(scenario: .paymentDue)
}

#Preview("Statement landed") {
    HomeReturningView(scenario: .statementLanded)
}

#Preview("Due date near") {
    HomeReturningView(scenario: .dueDateNear)
}
