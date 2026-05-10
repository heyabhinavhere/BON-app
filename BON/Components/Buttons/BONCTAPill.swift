import SwiftUI

struct BONCTAPill: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            Text(title)
                .font(BONTypography.cta)
                .foregroundStyle(BONColor.textOnDark)
                .lineLimit(1)
                .frame(width: 112, height: 33)
                .background(
                    Capsule(style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.21, green: 0.21, blue: 0.20),
                                    Color.black
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.white.opacity(0.22), lineWidth: 0.7)
                                .blur(radius: 0.5)
                        )
                        .bonShadow(.cta)
                )
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(title)
    }
}
