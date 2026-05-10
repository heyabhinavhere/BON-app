import SwiftUI

struct DesignAuditPlaceholderView: View {
    let environment: AppEnvironment

    var body: some View {
        NavigationStack {
            ZStack {
                BONColor.canvas.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: BONSpacing.xl) {
                        header
                        statusCard
                        nextStepsCard
                    }
                    .padding(.horizontal, BONSpacing.lg)
                    .padding(.top, BONSpacing.xxl)
                    .padding(.bottom, BONSpacing.xxxl)
                }
            }
            .navigationTitle("BON")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: BONSpacing.sm) {
            Text("Native iOS build")
                .font(BONTypography.display)
                .foregroundStyle(BONColor.ink)

            Text("The SwiftUI project is ready for the Figma audit and golden-screen implementation pass.")
                .font(BONTypography.body)
                .foregroundStyle(BONColor.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var statusCard: some View {
        BONSurface {
            VStack(alignment: .leading, spacing: BONSpacing.md) {
                Text("Design source")
                    .font(BONTypography.title2)
                    .foregroundStyle(BONColor.ink)

                InfoRow(label: "File key", value: environment.figmaFileKey)
                InfoRow(label: "Node", value: environment.figmaStartingNodeID)
                InfoRow(label: "Target", value: environment.primaryDeviceClass)
                InfoRow(label: "Minimum iOS", value: environment.minimumOSVersion)
            }
        }
    }

    private var nextStepsCard: some View {
        BONSurface {
            VStack(alignment: .leading, spacing: BONSpacing.md) {
                Text("Next implementation gate")
                    .font(BONTypography.title2)
                    .foregroundStyle(BONColor.ink)

                VStack(alignment: .leading, spacing: BONSpacing.sm) {
                    ChecklistRow(text: "Fetch Figma metadata and screenshot reference")
                    ChecklistRow(text: "Extract colors, typography, spacing, graphics, and states")
                    ChecklistRow(text: "Select the golden screen")
                    ChecklistRow(text: "Replace this audit screen with the first pixel-matched screen")
                }

                BONPrimaryButton(title: "Ready for Figma audit", systemImage: "checkmark.circle") {}
                    .padding(.top, BONSpacing.xs)
            }
        }
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(BONTypography.subheadline)
                .foregroundStyle(BONColor.tertiaryInk)

            Spacer(minLength: BONSpacing.md)

            Text(value)
                .font(BONTypography.subheadline.weight(.semibold))
                .foregroundStyle(BONColor.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct ChecklistRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: BONSpacing.sm) {
            Image(systemName: "circle")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(BONColor.tertiaryInk)
                .padding(.top, 2)

            Text(text)
                .font(BONTypography.subheadline)
                .foregroundStyle(BONColor.secondaryInk)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DesignAuditPlaceholderView(environment: .current)
}
