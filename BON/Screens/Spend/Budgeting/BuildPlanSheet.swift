import SwiftUI

/// Bottom-sheet style screen — Figma node 142:14636 ("Build your plan - select option").
///
/// Lets the user pick between manual entry and Plaid-linked accounts before they
/// commit to building a plan.
struct BuildPlanSheet: View {
    let onPickManual: () -> Void
    let onPickAutomatic: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BONSpacing.lg) {
            header

            VStack(spacing: 0) {
                planOptionRow(option: .manual) {
                    onPickManual()
                }

                Divider()
                    .overlay(BONColor.borderSubtle)
                    .padding(.horizontal, BONSpacing.lg)

                planOptionRow(option: .automatic) {
                    onPickAutomatic()
                }
            }

            plaidBranding

            Spacer(minLength: 0)
        }
        .padding(BONSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white)
                .ignoresSafeArea(edges: .bottom)
        )
        .presentationDetents([.fraction(0.78), .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }

    // MARK: - Subviews

    private var header: some View {
        HStack {
            Text("Build your plan")
                .font(BONTypography.zalando(size: 20, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
            Spacer()
            BudgetingCloseButton(action: onDismiss)
        }
    }

    private func planOptionRow(option: BuildPlanOption, action: @escaping () -> Void) -> some View {
        Button {
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            HStack(alignment: .center, spacing: BONSpacing.md) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(option.title)
                        .font(BONTypography.zalando(size: 16, weight: .semibold))
                        .foregroundStyle(BONColor.textPrimary)
                    Text(option.subtitle)
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .foregroundStyle(BONColor.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    Circle()
                        .fill(BONColor.lime500)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(BONColor.textPrimary)
                }
                .frame(width: 32, height: 32)
            }
            .padding(.vertical, BONSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(option.title). \(option.subtitle)")
    }

    private var plaidBranding: some View {
        VStack(spacing: BONSpacing.sm) {
            Text("BON Credit uses Plaid\nto link your account")
                .font(BONTypography.zalando(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(BONColor.textPrimary)
                .lineSpacing(2)

            HStack(spacing: BONSpacing.sm) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)

                BudgetingDashedDivider()
                    .frame(width: 56)
                    .padding(.horizontal, 4)

                Image(systemName: "circle.grid.cross.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(BONColor.textPrimary)
            }
            .padding(.vertical, 4)

            Text("used by")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)

            HStack(spacing: BONSpacing.xs) {
                brandBadge(symbol: "v.circle.fill", color: Color(red: 0.16, green: 0.45, blue: 0.95))
                brandBadge(symbol: "dollarsign.circle.fill", color: BONColor.lime500)
                brandBadge(symbol: "c.circle.fill", color: Color(red: 0.18, green: 0.71, blue: 0.42))
                brandBadge(symbol: "c.square.fill", color: Color(red: 0.10, green: 0.45, blue: 0.86))
            }

            Text("500M+ accounts connected through Plaid.")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(BONColor.textTertiary)
        }
        .frame(maxWidth: .infinity)
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
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(BONColor.borderSubtle.opacity(0.7), lineWidth: 1)
                )
        )
    }

    private func brandBadge(symbol: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(color)
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(width: 28, height: 28)
        .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        BONColor.canvas.ignoresSafeArea()
        BuildPlanSheet(
            onPickManual: {},
            onPickAutomatic: {},
            onDismiss: {}
        )
    }
}
