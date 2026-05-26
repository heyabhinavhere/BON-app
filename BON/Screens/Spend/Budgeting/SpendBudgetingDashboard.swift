import SwiftUI

/// Active budgeting dashboard — Figma node 142:12778 ("Spend - Budgeting").
///
/// Shows the user's locked plan with progress bars per category and a hero summary.
struct SpendBudgetingDashboard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var groups: [BudgetCategoryGroup]
    @State private var didAppear = false
    var onEditPlan: () -> Void = {}

    init(groups: [BudgetCategoryGroup] = BudgetCategoryGroup.activeDashboard, onEditPlan: @escaping () -> Void = {}) {
        _groups = State(initialValue: groups)
        self.onEditPlan = onEditPlan
    }

    private var allItems: [BudgetCategoryItem] {
        groups.flatMap(\.items)
    }

    private var totalBudget: Decimal { allItems.totalBudget }
    private var totalSpent: Decimal { allItems.totalSpent }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: BONSpacing.lg, pinnedViews: [.sectionHeaders]) {
                monthHeader
                    .padding(.horizontal, BONSpacing.screenHorizontal)
                    .padding(.top, BONSpacing.sm)

                heroCard
                    .padding(.horizontal, BONSpacing.screenHorizontal)
                    .opacity(didAppear ? 1 : 0)
                    .offset(y: didAppear ? 0 : 8)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.42), value: didAppear)

                ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                    Section {
                        VStack(spacing: 0) {
                            ForEach(group.items) { item in
                                DashboardBudgetRow(item: item)
                                if item.id != group.items.last?.id {
                                    Divider().overlay(BONColor.divider)
                                        .padding(.leading, 60)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal, BONSpacing.screenHorizontal)
                        .opacity(didAppear ? 1 : 0)
                        .offset(y: didAppear ? 0 : 14)
                        .animation(
                            reduceMotion ? nil : .easeOut(duration: 0.46).delay(0.08 + Double(index) * 0.04),
                            value: didAppear
                        )
                    } header: {
                        sectionHeader(title: group.title)
                            .padding(.horizontal, BONSpacing.screenHorizontal)
                    }
                }

                Color.clear.frame(height: 60)
            }
        }
        .background(BONColor.backgroundPrimary)
        .onAppear { didAppear = true }
    }

    // MARK: - Subviews

    private var monthHeader: some View {
        HStack {
            Text(currentMonthLabel)
                .font(BONTypography.zalando(size: 20, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            Spacer()
            Button {
                BONHaptics.selection()
                onEditPlan()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .stroke(BONColor.borderSubtle, lineWidth: 1)
                    )
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel("Edit plan")
        }
    }

    private var heroCard: some View {
        let progress = max(0, min(1, (totalSpent as NSDecimalNumber).doubleValue / max(1, (totalBudget as NSDecimalNumber).doubleValue)))
        return VStack(alignment: .leading, spacing: BONSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spending this month")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(BONColor.textTertiary)
                    Text(BudgetCurrency.string(from: totalSpent))
                        .font(BONTypography.geistPixel(size: 32))
                        .tracking(-0.64)
                        .foregroundStyle(BONColor.textPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Of plan")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(BONColor.textTertiary)
                    Text(BudgetCurrency.string(from: totalBudget))
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                }
            }

            BONLinearProgressBar(progress: progress, height: 16)
                .padding(.top, BONSpacing.xxs)

            Text("\(percentLabel(progress)) of plan used, \(Int(round((1 - progress) * 100)))% left")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
        }
        .padding(BONSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 14, x: 0, y: 8)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Spending this month, \(BudgetCurrency.string(from: totalSpent)) of \(BudgetCurrency.string(from: totalBudget))")
    }

    private func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(BONTypography.zalando(size: 13, weight: .medium))
                .tracking(0.4)
                .foregroundStyle(BONColor.textTertiary)
            Spacer()
        }
        .padding(.vertical, BONSpacing.xs)
        .background(BONColor.backgroundPrimary)
    }

    private var currentMonthLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    private func percentLabel(_ progress: Double) -> String {
        "\(Int(round(progress * 100)))%"
    }
}

// MARK: - Single budget row

private struct DashboardBudgetRow: View {
    let item: BudgetCategoryItem

    var body: some View {
        HStack(alignment: .center, spacing: BONSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(BONColor.lime100.opacity(0.5))
                Image(systemName: item.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.title)
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                        .lineLimit(1)
                    Spacer(minLength: BONSpacing.xs)
                    Text(BudgetCurrency.string(from: item.monthlyAmount))
                        .font(BONTypography.zalando(size: 13, weight: .medium))
                        .foregroundStyle(BONColor.textPrimary)
                }

                BONLinearProgressBar(
                    progress: item.progress,
                    height: 4,
                    isOverBudget: item.isOverBudget
                )

                HStack {
                    Text(progressDescription)
                        .font(BONTypography.zalando(size: 11, weight: .light))
                        .foregroundStyle(BONColor.textTertiary)
                    Spacer()
                    Text(remainingLabel)
                        .font(BONTypography.zalando(size: 11, weight: .medium))
                        .foregroundStyle(item.isOverBudget ? BONColor.error : BONColor.textTertiary)
                }
            }
        }
        .padding(.horizontal, BONSpacing.md)
        .padding(.vertical, BONSpacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var progressDescription: String {
        "\(BudgetCurrency.string(from: item.spent)) of \(BudgetCurrency.string(from: item.monthlyAmount))"
    }

    private var remainingLabel: String {
        if item.isOverBudget {
            let delta = item.spent - item.monthlyAmount
            return "+\(BudgetCurrency.string(from: delta)) over"
        }
        if item.monthlyAmount == 0 {
            return "Not budgeted"
        }
        return "\(BudgetCurrency.string(from: item.remaining)) left"
    }

    private var accessibilityLabel: String {
        "\(item.title), \(progressDescription), \(remainingLabel)"
    }
}

// MARK: - Linear progress bar

private struct BONLinearProgressBar: View {
    let progress: Double
    var height: CGFloat = 6
    var isOverBudget: Bool = false

    var body: some View {
        GeometryReader { proxy in
            let cleanProgress = min(1.0, max(0, progress))
            let overflow = max(0, progress - 1.0)
            let trackWidth = max(0, proxy.size.width)
            let filledWidth = trackWidth * CGFloat(cleanProgress)
            let overflowWidth = min(trackWidth * 0.35, trackWidth * CGFloat(overflow / 0.4))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(BONColor.lime50.opacity(0.6))

                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [BONColor.lime300, BONColor.lime500],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: filledWidth)

                if isOverBudget {
                    RoundedRectangle(cornerRadius: height / 2, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [BONColor.error.opacity(0.85), BONColor.error],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: overflowWidth)
                        .offset(x: filledWidth - 1)
                }
            }
            .frame(height: height)
        }
        .frame(height: height)
    }
}

#Preview("Spend dashboard") {
    ScrollView { SpendBudgetingDashboard() }
        .background(BONColor.backgroundPrimary)
}
