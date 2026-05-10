import SwiftUI

extension View {
    func bonHeroGlow(cornerRadius: CGFloat = BONRadius.hero) -> some View {
        self
            .shadow(color: BONColor.limeGlow.opacity(0.34), radius: 14, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BONColor.limeGlow.opacity(0.72), lineWidth: 1)
                    .blur(radius: 2)
                    .padding(1)
            )
    }

    func bonPressedScale(_ isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.965 : 1)
            .animation(BONMotion.press, value: isPressed)
    }
}
