import SwiftUI

struct BONIconButton: View {
    let imageAsset: String
    let accessibilityLabel: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.selection()
                action()
            }
        } label: {
            Image(imageAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: 16, height: 16)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(BONColor.surfacePrimary.opacity(0.88))
                        .shadow(color: Color.black.opacity(0.08), radius: 32, x: 0, y: 8)
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

struct BONScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bonPressedScale(configuration.isPressed)
    }
}
