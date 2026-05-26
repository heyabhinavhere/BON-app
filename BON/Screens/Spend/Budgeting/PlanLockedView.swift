import SwiftUI

/// Plan-locked confirmation — Figma node 142:12642.
///
/// Shown after the user finishes building their plan. Displays the locked summary and
/// nudges the user to optionally link credit cards / bank so transactions can be tracked
/// automatically.
struct PlanLockedView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var badgePulse: CGFloat = 0
    @State private var didAppear = false

    let summary: [BudgetCategoryGroup]
    let onClose: () -> Void
    let onContinue: () -> Void
    let onLinkCard: () -> Void
    let onLinkBank: () -> Void

    init(
        summary: [BudgetCategoryGroup] = BudgetCategoryGroup.lockedSummary,
        onClose: @escaping () -> Void,
        onContinue: @escaping () -> Void,
        onLinkCard: @escaping () -> Void = {},
        onLinkBank: @escaping () -> Void = {}
    ) {
        self.summary = summary
        self.onClose = onClose
        self.onContinue = onContinue
        self.onLinkCard = onLinkCard
        self.onLinkBank = onLinkBank
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: BONSpacing.lg) {
                navBar

                centerBadge
                    .frame(maxWidth: .infinity)
                    .padding(.top, BONSpacing.lg)

                heroCopy

                summaryCard

                linkAccountsCard

                Spacer(minLength: 100)
            }
            .padding(.horizontal, BONSpacing.screenHorizontal)
            .padding(.top, BONSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(BONColor.backgroundPrimary)
        .overlay(alignment: .bottom) {
            bottomCTA
        }
        .onAppear(perform: animateBadge)
    }

    // MARK: - Subviews

    private var navBar: some View {
        HStack {
            Text("Plan locked")
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            Spacer()
            BudgetingCloseButton(action: onClose)
        }
    }

    private var centerBadge: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { ray in
                Capsule()
                    .fill(BONColor.lime400.opacity(0.95))
                    .frame(width: 14, height: 14)
                    .offset(y: -22)
                    .rotationEffect(.degrees(Double(ray) * 45))
            }
            .scaleEffect(1 + badgePulse * 0.08)

            Circle()
                .fill(BONColor.lime400)
                .frame(width: 32, height: 32)

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(BONColor.textPrimary)
        }
        .frame(width: 56, height: 56)
        .scaleEffect(1 + badgePulse * 0.04)
        .accessibilityHidden(true)
    }

    private var heroCopy: some View {
        Text("I'll track every dollar. End of May we'll review and tweak together.")
            .font(BONTypography.zalando(size: 20, weight: .medium))
            .foregroundStyle(BONColor.textPrimary)
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.top, BONSpacing.xs)
    }

    private var summaryCard: some View {
        let items = summary.flatMap(\.items)
        return VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                BudgetingLockedSummaryRow(
                    title: item.title,
                    amount: BudgetCurrency.string(from: item.monthlyAmount),
                    highlighted: index == 0
                )

                if item.id != items.last?.id {
                    Divider().overlay(BONColor.divider)
                        .padding(.horizontal, BONSpacing.lg)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
        )
        .padding(.top, BONSpacing.md)
    }

    private var linkAccountsCard: some View {
        VStack(spacing: BONSpacing.md) {
            VStack(spacing: 6) {
                Text("One more thing")
                    .font(BONTypography.zalando(size: 16, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
                Text("Link your credit cards and bank and I'll auto-track every transaction. No more typing. It's free.")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, BONSpacing.sm)
            }

            HStack(spacing: BONSpacing.md) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
                BudgetingDashedDivider().frame(width: 56)
                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .padding(.vertical, BONSpacing.xs)
            .accessibilityHidden(true)

            VStack(spacing: BONSpacing.sm) {
                Button {
                    Task { @MainActor in
                        BONHaptics.impact(.light)
                        onLinkCard()
                    }
                } label: {
                    Text("Link credit cards")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.black)
                        )
                }
                .buttonStyle(BONScaleButtonStyle())
                .accessibilityLabel("Link credit cards")

                Button {
                    Task { @MainActor in
                        BONHaptics.selection()
                        onLinkBank()
                    }
                } label: {
                    Text("Link bank account")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            Capsule(style: .continuous)
                                .stroke(BONColor.textPrimary, lineWidth: 1.2)
                                .background(Capsule(style: .continuous).fill(Color.white))
                        )
                }
                .buttonStyle(BONScaleButtonStyle())
                .accessibilityLabel("Link bank account")
            }
        }
        .padding(BONSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BONColor.lime100.opacity(0.7), Color.white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    GeometryReader { proxy in
                        let scaleX = proxy.size.width / 174
                        BudgetingDotScatter(
                            scaleX: scaleX,
                            color: BONColor.lime600,
                            height: 35
                        )
                        .padding(.top, 6)
                        .opacity(didAppear ? 0.45 : 0)
                        .animation(reduceMotion ? nil : .easeOut(duration: 0.6).delay(0.12), value: didAppear)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(BONColor.borderSubtle.opacity(0.7), lineWidth: 1)
                )
        )
        .padding(.top, BONSpacing.md)
        .onAppear { didAppear = true }
    }

    private var bottomCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            HStack {
                Text("Skip for now")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)
                    .onTapGesture {
                        BONHaptics.selection()
                        onContinue()
                    }
                    .accessibilityAddTraits(.isButton)

                Spacer()

                Button {
                    BONHaptics.selection()
                    onContinue()
                } label: {
                    HStack(spacing: 4) {
                        Text("View dashboard")
                        Image(systemName: "arrow.right")
                    }
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .foregroundStyle(BONColor.textPrimary)
                }
                .buttonStyle(BONScaleButtonStyle())
                .accessibilityLabel("View dashboard")
            }
            .padding(.horizontal, BONSpacing.screenHorizontal)
            .padding(.vertical, BONSpacing.sm)
            .background(BONColor.backgroundPrimary)
        }
    }

    // MARK: - Animation

    private func animateBadge() {
        guard !reduceMotion else { return }
        badgePulse = 0

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 220_000_000)
            withAnimation(.spring(response: 0.32, dampingFraction: 0.62)) {
                badgePulse = 1
            }
            try? await Task.sleep(nanoseconds: 380_000_000)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.78)) {
                badgePulse = 0
            }
        }
    }
}

#Preview("Plan locked") {
    PlanLockedView(
        onClose: {},
        onContinue: {}
    )
}
