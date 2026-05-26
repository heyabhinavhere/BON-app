import SwiftUI

/// Top-level Spend screen. Mirrors the Figma frame 142:12604 header chrome (page title +
/// three sub-tabs) and routes each tab to its own content view.
///
/// The Budgeting tab hosts the full first-time budgeting funnel via `SpendBudgetingFlow`.
/// Transactions and Recurring are placeholders pending their own Figma references.
struct SpendView: View {
    @State private var selection: SpendSubTab

    /// Optional override so deep-links or previews can land on a specific sub-tab.
    init(initial: SpendSubTab = .budgeting) {
        _selection = State(initialValue: initial)
    }

    var body: some View {
        VStack(spacing: 0) {
            SpendHeader(title: "Your spends", selection: $selection)

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(BONColor.backgroundPrimary)
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .transactions:
            SpendPlaceholderTab(
                symbol: "list.bullet.rectangle.fill",
                title: "Transactions",
                message: "Your live transactions will appear here once accounts are linked."
            )
        case .recurring:
            SpendPlaceholderTab(
                symbol: "repeat.circle.fill",
                title: "Recurring",
                message: "We'll flag recurring charges and subscriptions on this tab."
            )
        case .budgeting:
            SpendBudgetingFlow()
        }
    }
}

private struct SpendPlaceholderTab: View {
    let symbol: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: BONSpacing.md) {
            Spacer()
            Image(systemName: symbol)
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(BONColor.textTertiary)
            Text(title)
                .font(BONTypography.zalando(size: 18, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            Text(message)
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)
            Spacer()
        }
        .padding(.horizontal, BONSpacing.screenHorizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
}

#Preview("Spend — Budgeting") {
    SpendView(initial: .budgeting)
}

#Preview("Spend — Transactions") {
    SpendView(initial: .transactions)
}
