import SwiftUI

struct BONPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled, !isLoading else { return }
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            HStack(spacing: BONSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.small)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(BONTypography.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BONPrimaryButtonStyle(isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

private struct BONPrimaryButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, BONSpacing.lg)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: BONRadius.pill, style: .continuous)
                    .fill(isDisabled ? BONColor.tertiaryInk : (configuration.isPressed ? BONColor.brandPressed : BONColor.brand))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(BONMotion.press, value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: BONSpacing.md) {
        BONPrimaryButton(title: "Continue", systemImage: "arrow.right") {}
        BONPrimaryButton(title: "Loading", isLoading: true) {}
        BONPrimaryButton(title: "Disabled", isDisabled: true) {}
    }
    .padding()
    .background(BONColor.canvas)
}
