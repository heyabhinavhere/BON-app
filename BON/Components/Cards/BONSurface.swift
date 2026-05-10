import SwiftUI

struct BONSurface<Content: View>: View {
    var cornerRadius: CGFloat = BONRadius.lg
    var padding: CGFloat = BONSpacing.lg
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(BONColor.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(BONColor.line.opacity(0.7), lineWidth: 1)
            )
            .bonShadow(.subtle)
    }
}

#Preview {
    BONSurface {
        VStack(alignment: .leading, spacing: BONSpacing.xs) {
            Text("Surface")
                .font(BONTypography.headline)
                .foregroundStyle(BONColor.ink)
            Text("Reusable card primitive for Figma-matched surfaces.")
                .font(BONTypography.subheadline)
                .foregroundStyle(BONColor.secondaryInk)
        }
    }
    .padding()
    .background(BONColor.canvas)
}
