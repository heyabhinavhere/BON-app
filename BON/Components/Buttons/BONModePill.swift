import SwiftUI

struct BONModePill: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            Text(title)
                .font(BONTypography.caption)
                .foregroundStyle(BONColor.textTertiary)
                .frame(width: 110, height: 40)
                .background(
                    Capsule(style: .continuous)
                        .fill(BONColor.surfacePrimary.opacity(0.76))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(BONColor.borderSubtle.opacity(0.65), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 8)
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}
