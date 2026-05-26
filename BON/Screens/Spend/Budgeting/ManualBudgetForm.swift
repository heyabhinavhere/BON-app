import SwiftUI

/// Manual budget entry form — Figma node 142:15083 ("Build your plan - fill details manually").
///
/// The Figma source is a tall scrolling form with nine grouped sections. We render the
/// same hierarchy here using SwiftUI primitives and the project's design system tokens.
struct ManualBudgetForm: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var groups: [BudgetCategoryGroup]
    @State private var focusGroupID: String?
    @FocusState private var focusedItemID: String?

    let onCancel: () -> Void
    let onSubmit: ([BudgetCategoryGroup]) -> Void

    init(
        initial: [BudgetCategoryGroup] = BudgetCategoryGroup.starterTemplate,
        onCancel: @escaping () -> Void,
        onSubmit: @escaping ([BudgetCategoryGroup]) -> Void
    ) {
        _groups = State(initialValue: initial)
        self.onCancel = onCancel
        self.onSubmit = onSubmit
    }

    var body: some View {
        VStack(spacing: 0) {
            navigationStrip

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: BONSpacing.xl, pinnedViews: []) {
                    intro
                        .padding(.horizontal, BONSpacing.screenHorizontal)
                        .padding(.top, BONSpacing.md)

                    ForEach($groups) { $group in
                        BudgetGroupSection(group: $group, focusedItemID: $focusedItemID)
                            .padding(.horizontal, BONSpacing.screenHorizontal)
                    }

                    Color.clear.frame(height: 132)
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(formBackground)
        .overlay(alignment: .bottom) {
            stickyCTA
        }
    }

    // MARK: - Subviews

    private var navigationStrip: some View {
        HStack {
            Button {
                BONHaptics.selection()
                onCancel()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Back")
                        .font(BONTypography.zalando(size: 14, weight: .regular))
                }
                .foregroundStyle(BONColor.textTertiary)
            }
            .buttonStyle(BONScaleButtonStyle())
            .accessibilityLabel("Back")

            Spacer()

            BudgetingMonthPill(month: "May 2026", isLocked: false)
        }
        .padding(.horizontal, BONSpacing.screenHorizontal)
        .padding(.vertical, BONSpacing.sm)
        .background(BONColor.backgroundPrimary)
    }

    private var intro: some View {
        HStack {
            Text("Enter your details to build your plan")
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            Spacer()
        }
        .padding(BONSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(BONColor.lime100.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BONColor.lime300.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private var formBackground: some View {
        LinearGradient(
            colors: [
                BONColor.lime100.opacity(0.35),
                Color.white
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var stickyCTA: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            ZStack {
                BONColor.backgroundPrimary
                BONIntentCTA(title: "Save and build plan") {
                    onSubmit(groups)
                }
                .frame(height: 48)
                .padding(.horizontal, BONSpacing.screenHorizontal)
                .padding(.vertical, BONSpacing.sm)
            }
        }
    }
}

// MARK: - Group section

private struct BudgetGroupSection: View {
    @Binding var group: BudgetCategoryGroup
    @FocusState.Binding var focusedItemID: String?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(group.title)
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .foregroundStyle(BONColor.textPrimary)
                Spacer()
            }
            .padding(.vertical, BONSpacing.sm)

            VStack(spacing: 0) {
                ForEach($group.items) { $item in
                    BudgetEntryRow(item: $item, focusedItemID: $focusedItemID)

                    if item.id != group.items.last?.id {
                        Divider().overlay(BONColor.divider.opacity(0.6))
                    }
                }

                addRowButton
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            )
        }
    }

    private var addRowButton: some View {
        Button {
            BONHaptics.selection()
            let newItem = BudgetCategoryItem(
                id: "\(group.id).custom.\(UUID().uuidString.prefix(6))",
                title: "New item",
                symbol: "plus.circle.fill",
                monthlyAmount: 0,
                spent: 0
            )
            group.items.append(newItem)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .semibold))
                Text("Add another")
                    .font(BONTypography.zalando(size: 13, weight: .regular))
            }
            .foregroundStyle(BONColor.textTertiary)
            .padding(.horizontal, BONSpacing.sm)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .stroke(BONColor.borderSubtle, lineWidth: 1)
                    .background(Capsule(style: .continuous).fill(Color.white))
            )
        }
        .buttonStyle(BONScaleButtonStyle())
        .padding(BONSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityLabel("Add another row to \(group.title)")
    }
}

// MARK: - Single editable row

private struct BudgetEntryRow: View {
    @Binding var item: BudgetCategoryItem
    @FocusState.Binding var focusedItemID: String?
    @State private var amountString: String = ""

    var body: some View {
        HStack(spacing: BONSpacing.sm) {
            ZStack {
                Circle()
                    .fill(BONColor.lime100.opacity(0.45))
                Image(systemName: item.symbol)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .frame(width: 28, height: 28)

            Text(item.title)
                .font(BONTypography.zalando(size: 15, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.86)

            Spacer(minLength: BONSpacing.xs)

            HStack(spacing: 2) {
                Text("$")
                    .font(BONTypography.zalando(size: 15, weight: .regular))
                    .foregroundStyle(BONColor.textTertiary)

                TextField("0", text: $amountString)
                    .keyboardType(.decimalPad)
                    .focused($focusedItemID, equals: item.id)
                    .font(BONTypography.zalando(size: 15, weight: .medium))
                    .foregroundStyle(BONColor.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .frame(minWidth: 32, maxWidth: 80)
                    .onChange(of: amountString) { _, newValue in
                        applyAmount(newValue)
                    }
            }
        }
        .padding(.horizontal, BONSpacing.md)
        .padding(.vertical, BONSpacing.sm)
        .contentShape(Rectangle())
        .onAppear {
            amountString = item.monthlyAmount == 0 ? "" : String(describing: item.monthlyAmount)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title), amount in dollars")
    }

    private func applyAmount(_ raw: String) {
        let cleaned = raw.replacingOccurrences(of: ",", with: ".")
        if cleaned.isEmpty {
            item.monthlyAmount = 0
            return
        }
        if let decimal = Decimal(string: cleaned) {
            item.monthlyAmount = decimal
        }
    }
}

#Preview("Manual form") {
    ManualBudgetForm(onCancel: {}, onSubmit: { _ in })
}
