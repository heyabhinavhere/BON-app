import SwiftUI

// MARK: - Sub-tab pill segmented control ("Transactions / Recurring / Budgeting")

struct SpendSubTabBar: View {
    @Binding var selection: SpendSubTab
    var width: CGFloat = BONSpacing.contentWidth

    var body: some View {
        HStack(spacing: BONSpacing.xs) {
            ForEach(SpendSubTab.allCases) { tab in
                pill(for: tab)
            }
        }
        .padding(4)
        .frame(width: width, height: 39)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.10))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(BONColor.borderSubtle, lineWidth: 1)
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        .blur(radius: 2)
                        .blendMode(.multiply)
                        .opacity(0.18)
                )
        )
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private func pill(for tab: SpendSubTab) -> some View {
        let isSelected = tab == selection
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                withAnimation(BONMotion.reveal) {
                    selection = tab
                }
            }
        } label: {
            Text(tab.title)
                .font(BONTypography.zalando(size: 12, weight: isSelected ? .medium : .regular))
                .foregroundStyle(isSelected ? Color.white : BONColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 31)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color.black : Color.black.opacity(0.04))
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(tab.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Spend top bar (page title + tabs + divider)

struct SpendHeader: View {
    let title: String
    @Binding var selection: SpendSubTab
    var trailingAction: (() -> Void)?

    var body: some View {
        VStack(spacing: BONSpacing.md) {
            HStack {
                Text(title)
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(BONColor.textPrimary)
                Spacer()
                if let trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(BONColor.textPrimary)
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(BONScaleButtonStyle())
                    .accessibilityLabel("Options")
                }
            }
            .padding(.horizontal, BONSpacing.screenHorizontal)

            SpendSubTabBar(selection: $selection)

            Divider().overlay(BONColor.borderSubtle)
                .padding(.horizontal, BONSpacing.screenHorizontal)
        }
        .padding(.top, BONSpacing.lg)
        .background(BONColor.backgroundPrimary)
    }
}

// MARK: - Value pill (the small lime chip with an icon used in the intro)

struct BudgetingValueChip: View {
    let symbol: String
    let title: String
    var width: CGFloat = 84

    var body: some View {
        VStack(spacing: BONSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(BONColor.lime100)
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .frame(width: 32, height: 32)

            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: width)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

// MARK: - Compact bar-chart card (intro "Money left this month")

struct BudgetingBarChartCard: View {
    var moneyLeftLabel: String = "Money left this month"
    var amount: String = "$612"
    /// 0-19 cells, lit/intensity ramp matches Figma frame 142:12515 spending visualization.
    var litCount: Int = 9
    var width: CGFloat = 256

    private let totalBars = 20

    var body: some View {
        VStack(alignment: .leading, spacing: BONSpacing.xs) {
            VStack(alignment: .leading, spacing: 2) {
                Text(moneyLeftLabel)
                    .font(BONTypography.zalando(size: 10, weight: .light))
                    .foregroundStyle(BONColor.textPrimary)
                Text(amount)
                    .font(BONTypography.geistPixel(size: 24))
                    .tracking(-0.48)
                    .foregroundStyle(BONColor.textPrimary)
            }

            HStack(spacing: 4) {
                ForEach(0..<totalBars, id: \.self) { index in
                    barCell(at: index)
                }
            }
            .frame(width: max(0, width - 24))
        }
        .padding(.horizontal, BONSpacing.sm)
        .padding(.vertical, BONSpacing.xs)
        .frame(width: width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(moneyLeftLabel), \(amount)")
    }

    private func barCell(at index: Int) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(BONColor.lime50.opacity(0.4))

            if index < litCount {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(intensityColor(for: index))
            }

            if index == litCount - 1 {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(Color.black.opacity(0.85), lineWidth: 0.8)
            }
        }
        .frame(width: 8, height: 20)
    }

    private func intensityColor(for index: Int) -> Color {
        let progress = Double(index) / Double(max(litCount - 1, 1))
        switch progress {
        case ..<0.25: return BONColor.lime50
        case ..<0.5:  return BONColor.lime100
        case ..<0.75: return BONColor.lime200
        default:       return BONColor.lime300
        }
    }
}

// MARK: - Tiny floating chip used in the intro hero ("Chase bill due | $124")

struct BudgetingBillChip: View {
    let title: String
    let amount: String

    var body: some View {
        HStack(spacing: BONSpacing.xs) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(BONColor.borderSubtle, lineWidth: 1))
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(red: 0.07, green: 0.34, blue: 0.71))
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .tracking(0.28)
                    .foregroundStyle(BONColor.textPrimary)
                Text(amount)
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
            }
        }
        .padding(BONSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(BONColor.borderSubtle, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(amount)")
    }
}

// MARK: - Lime "AI suggests" bubble used in intro

struct BudgetingAISuggestBubble: View {
    let body0: String

    var body: some View {
        HStack(alignment: .top, spacing: BONSpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(BONColor.lime700)
                .padding(.top, 1)

            (
                Text("AI suggests: ")
                    .font(BONTypography.zalando(size: 12, weight: .medium))
                    .foregroundStyle(BONColor.lime700)
                +
                Text(body0)
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textPrimary)
            )
            .lineSpacing(2)
        }
        .padding(BONSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 4)
        )
        .accessibilityLabel("AI suggests. \(body0)")
    }
}

// MARK: - Lime gradient hero card backing the intro graphic

struct BudgetingHeroGradient: View {
    var cornerRadius: CGFloat = 24

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [BONColor.lime100, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}

// MARK: - Close button used across the budgeting flow

struct BudgetingCloseButton: View {
    let action: () -> Void
    var accessibilityLabel: String = "Close"

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.92))
                    .overlay(Circle().stroke(BONColor.borderSubtle, lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .frame(width: 32, height: 32)
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Dashed divider used across budgeting screens

struct BudgetingDashedDivider: View {
    var color: Color = BONColor.divider

    var body: some View {
        GeometryReader { proxy in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: proxy.size.width, y: 0))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
        }
        .frame(height: 1)
    }
}

// MARK: - Locked-plan summary card body (used on PlanLockedView)

struct BudgetingLockedSummaryRow: View {
    let title: String
    let amount: String
    var highlighted: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(highlighted ? BONColor.lime600 : BONColor.textPrimary)
            Spacer()
            Text(amount)
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(highlighted ? BONColor.lime600 : BONColor.textPrimary)
        }
        .padding(.vertical, BONSpacing.sm)
        .padding(.horizontal, BONSpacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(amount)")
    }
}

// MARK: - Confetti dot scatter (decorative band above CTAs in plan-locked card)

struct BudgetingDotScatter: View {
    struct Dot {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }

    /// Lifted directly from the Figma node 142:12683 ellipse positions so the scatter
    /// matches the designed feel without exporting an SVG asset.
    private static let dots: [Dot] = [
        Dot(x: 14, y: 10, size: 3, opacity: 0.72),
        Dot(x: 18, y: 3, size: 3, opacity: 0.45),
        Dot(x: 24, y: 15, size: 3, opacity: 0.62),
        Dot(x: 36, y: 3, size: 3, opacity: 0.55),
        Dot(x: 39, y: 15, size: 3, opacity: 0.78),
        Dot(x: 48, y: 9, size: 3, opacity: 0.50),
        Dot(x: 56, y: 22, size: 3, opacity: 0.66),
        Dot(x: 60, y: 12, size: 3, opacity: 0.42),
        Dot(x: 54, y: 1, size: 3, opacity: 0.34),
        Dot(x: 44, y: 27, size: 3, opacity: 0.60),
        Dot(x: 78, y: 32, size: 3, opacity: 0.38),
        Dot(x: 28, y: 31, size: 3, opacity: 0.56),
        Dot(x: 9, y: 22, size: 3, opacity: 0.48),
        Dot(x: 19, y: 30, size: 3, opacity: 0.38),
        Dot(x: 3, y: 11, size: 3, opacity: 0.40),
        Dot(x: 0, y: 29, size: 3, opacity: 0.36),
        Dot(x: 31, y: 21, size: 3, opacity: 0.62),
        Dot(x: 63, y: 29, size: 3, opacity: 0.44),
        Dot(x: 79, y: 12, size: 3, opacity: 0.40),
        Dot(x: 67, y: 5, size: 3, opacity: 0.36),
        Dot(x: 74, y: 18, size: 3, opacity: 0.56),
        Dot(x: 84, y: 4, size: 3, opacity: 0.32),
        Dot(x: 91, y: 14, size: 3, opacity: 0.46),
        Dot(x: 103, y: 3, size: 3, opacity: 0.30),
        Dot(x: 110, y: 12, size: 3, opacity: 0.40),
        Dot(x: 124, y: 7, size: 3, opacity: 0.36),
        Dot(x: 132, y: 19, size: 3, opacity: 0.42),
        Dot(x: 145, y: 6, size: 3, opacity: 0.34),
        Dot(x: 158, y: 14, size: 3, opacity: 0.46),
        Dot(x: 172, y: 4, size: 3, opacity: 0.32)
    ]

    let scaleX: CGFloat
    let color: Color
    var height: CGFloat = 35

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(Self.dots.enumerated()), id: \.offset) { _, dot in
                Circle()
                    .fill(color.opacity(dot.opacity))
                    .frame(width: dot.size, height: dot.size)
                    .position(x: dot.x * scaleX, y: dot.y)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .accessibilityHidden(true)
    }
}

// MARK: - Tight pill segmented (used for stepper-like context)

struct BudgetingMonthPill: View {
    let month: String
    let isLocked: Bool

    var body: some View {
        HStack(spacing: BONSpacing.xs) {
            Text(month)
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            if isLocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(BONColor.textTertiary)
            }
        }
        .padding(.horizontal, BONSpacing.sm)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(BONColor.lime100.opacity(0.45))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(month)\(isLocked ? ", locked" : "")")
    }
}
