import SwiftUI

/// Pre-plan landing screen — Figma node 142:12510 ("Spend - Budgeting_first time").
///
/// Rendered inside the Spend → Budgeting tab when the user has not yet built a plan.
/// Tapping `Build your plan` opens the build-plan selector sheet.
struct BudgetingIntroView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var revealProgress: CGFloat = 0
    @State private var heroFloat: CGFloat = 0

    let onBuildPlan: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BONSpacing.xxl) {
            headlineBlock
                .opacity(reveal(start: 0.0, end: 0.4))
                .offset(y: (1 - reveal(start: 0.0, end: 0.4)) * 8)

            heroPanel
                .opacity(reveal(start: 0.15, end: 0.65))
                .offset(y: (1 - reveal(start: 0.15, end: 0.65)) * 14)

            valuePillsRow
                .opacity(reveal(start: 0.40, end: 0.85))
                .offset(y: (1 - reveal(start: 0.40, end: 0.85)) * 10)

            Spacer(minLength: 0)

            VStack(spacing: BONSpacing.sm) {
                BONIntentCTA(title: "Build your plan", revealProgress: revealProgress) {
                    onBuildPlan()
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)

                Text("Change or cancel anytime")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .opacity(reveal(start: 0.55, end: 0.95))
        }
        .padding(.horizontal, BONSpacing.screenHorizontal)
        .padding(.top, BONSpacing.lg)
        .padding(.bottom, BONSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BONColor.backgroundPrimary)
        .onAppear(perform: startReveal)
    }

    // MARK: - Subviews

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: BONSpacing.xs) {
            Text("Know where every dollar goes.")
                .font(BONTypography.zalando(size: 20, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            Text("Plan your month. Hit your goals. All for Free.")
                .font(BONTypography.zalando(size: 16, weight: .light))
                .foregroundStyle(BONColor.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroPanel: some View {
        ZStack(alignment: .topLeading) {
            BudgetingHeroGradient(cornerRadius: 24)
                .frame(height: 233)

            BudgetingBarChartCard()
                .padding(.leading, 20)
                .padding(.top, 24)
                .offset(y: heroFloat * -2)
                .animation(reduceMotion ? nil : .easeInOut(duration: 4.6).repeatForever(autoreverses: true), value: heroFloat)

            BudgetingBillChip(title: "Chase bill due", amount: "$124")
                .padding(.leading, 175)
                .padding(.top, 85)
                .offset(y: heroFloat * 2)

            BudgetingAISuggestBubble(
                body0: "You're on track. Food delivery's $24 over; want to bump?"
            )
            .frame(width: 236)
            .padding(.leading, 53)
            .padding(.top, 153)
        }
        .frame(height: 233)
        .accessibilityElement(children: .contain)
    }

    private var valuePillsRow: some View {
        HStack(alignment: .top, spacing: 0) {
            BudgetingValueChip(symbol: "checkmark", title: "Tie it to debt and savings", width: 100)
                .frame(maxWidth: .infinity)
            BudgetingValueChip(symbol: "checkmark", title: "Plan around your real income", width: 114)
                .frame(maxWidth: .infinity)
            BudgetingValueChip(symbol: "checkmark", title: "I watch, you decide", width: 88)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Reveal animation

    private func startReveal() {
        guard !reduceMotion else {
            revealProgress = 1
            return
        }

        revealProgress = 0
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000)
            withAnimation(.easeOut(duration: 0.78)) {
                revealProgress = 1
            }
            try? await Task.sleep(nanoseconds: 320_000_000)
            withAnimation(.easeInOut(duration: 4.6).repeatForever(autoreverses: true)) {
                heroFloat = 1
            }
        }
    }

    private func reveal(start: CGFloat, end: CGFloat) -> CGFloat {
        let p = min(1, max(0, revealProgress))
        guard end > start else { return p }
        let progress = (p - start) / (end - start)
        return min(1, max(0, progress))
    }
}

#Preview("Intro") {
    BudgetingIntroView(onBuildPlan: {})
        .background(BONColor.backgroundPrimary)
}
