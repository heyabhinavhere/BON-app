import SwiftUI

/// Drives the first-time budgeting funnel inside the Spend → Budgeting tab.
///
/// Self-contained — owns its own `stage` state machine so the flow can be embedded
/// anywhere without touching the global `AppRoute` enum. The state transitions match
/// the Figma flow:
///
///   intro ─▶ (sheet) ─▶ manualEntry ─▶ planLocked ─▶ dashboard
///
/// On `dashboard` the view stays put — subsequent visits should construct the dashboard
/// directly via `SpendBudgetingDashboard`.
struct SpendBudgetingFlow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var stage: SpendBudgetingStage = .intro
    @State private var isBuildPlanSheetPresented = false
    @State private var draftGroups: [BudgetCategoryGroup] = BudgetCategoryGroup.starterTemplate
    @State private var lockedGroups: [BudgetCategoryGroup] = BudgetCategoryGroup.lockedSummary

    /// External callers can override the starting stage (e.g. SwiftUI Previews or once
    /// the home agent wires the `Build your plan` CTA from `FirstTimerBudgetingView`).
    init(initialStage: SpendBudgetingStage = .intro) {
        _stage = State(initialValue: initialStage)
    }

    var body: some View {
        ZStack {
            switch stage {
            case .intro:
                BudgetingIntroView(onBuildPlan: openBuildPlanSheet)
                    .transition(stageTransition)
            case .manualEntry:
                ManualBudgetForm(
                    initial: draftGroups,
                    onCancel: { transition(to: .intro) },
                    onSubmit: handleManualFormSubmit
                )
                .transition(stageTransition)
            case .planLocked:
                PlanLockedView(
                    summary: lockedGroups,
                    onClose: { transition(to: .intro) },
                    onContinue: { transition(to: .dashboard) }
                )
                .transition(stageTransition)
            case .dashboard:
                SpendBudgetingDashboard(onEditPlan: { transition(to: .manualEntry) })
                    .transition(stageTransition)
            }
        }
        .sheet(isPresented: $isBuildPlanSheetPresented) {
            BuildPlanSheet(
                onPickManual: pickManual,
                onPickAutomatic: pickAutomatic,
                onDismiss: { isBuildPlanSheetPresented = false }
            )
        }
        .animation(stageAnimation, value: stage)
    }

    // MARK: - Actions

    private func openBuildPlanSheet() {
        Task { @MainActor in
            BONHaptics.impact(.light)
            isBuildPlanSheetPresented = true
        }
    }

    private func pickManual() {
        Task { @MainActor in
            BONHaptics.selection()
            isBuildPlanSheetPresented = false
            try? await Task.sleep(nanoseconds: 280_000_000)
            transition(to: .manualEntry)
        }
    }

    private func pickAutomatic() {
        // Placeholder: a future PR can launch the Plaid linking flow. For now we treat
        // this as "use the example data" so the user can still preview the locked plan.
        Task { @MainActor in
            BONHaptics.selection()
            isBuildPlanSheetPresented = false
            try? await Task.sleep(nanoseconds: 280_000_000)
            lockedGroups = BudgetCategoryGroup.lockedSummary
            transition(to: .planLocked)
        }
    }

    private func handleManualFormSubmit(_ groups: [BudgetCategoryGroup]) {
        Task { @MainActor in
            BONHaptics.success()
            draftGroups = groups
            lockedGroups = lockedSummary(from: groups)
            transition(to: .planLocked)
        }
    }

    @MainActor
    private func transition(to next: SpendBudgetingStage) {
        withAnimation(stageAnimation) {
            stage = next
        }
    }

    // MARK: - Helpers

    private var stageTransition: AnyTransition {
        if reduceMotion { return .opacity }
        return .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        )
    }

    private var stageAnimation: Animation {
        reduceMotion ? BONMotion.reducedMotionFallback : BONMotion.reveal
    }

    /// Collapse the per-item draft into the four high-level rows the Figma locked
    /// summary card displays (Incoming, Housing, Transportation, Personal).
    private func lockedSummary(from groups: [BudgetCategoryGroup]) -> [BudgetCategoryGroup] {
        func total(for groupID: String) -> Decimal {
            guard let group = groups.first(where: { $0.id == groupID }) else { return 0 }
            return group.items.totalBudget
        }

        let incoming = total(for: "income")
        let housing = total(for: "housing")
        let transport = total(for: "transport")
        let personal = total(for: "personal") + total(for: "lifestyle")

        return [
            BudgetCategoryGroup(
                id: "summary",
                title: "Summary",
                items: [
                    BudgetCategoryItem(id: "summary.incoming", title: "Incoming", symbol: "arrow.down.circle.fill", monthlyAmount: incoming, spent: 0),
                    BudgetCategoryItem(id: "summary.housing", title: "Housing", symbol: "house.fill", monthlyAmount: housing, spent: 0),
                    BudgetCategoryItem(id: "summary.transport", title: "Transportation", symbol: "car.fill", monthlyAmount: transport, spent: 0),
                    BudgetCategoryItem(id: "summary.personal", title: "Personal", symbol: "person.fill", monthlyAmount: personal, spent: 0)
                ]
            )
        ]
    }
}

#Preview("Flow — Intro") {
    SpendBudgetingFlow(initialStage: .intro)
}

#Preview("Flow — Manual entry") {
    SpendBudgetingFlow(initialStage: .manualEntry)
}

#Preview("Flow — Plan locked") {
    SpendBudgetingFlow(initialStage: .planLocked)
}

#Preview("Flow — Dashboard") {
    SpendBudgetingFlow(initialStage: .dashboard)
}
