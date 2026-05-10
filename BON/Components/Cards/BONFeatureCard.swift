import SwiftUI

struct BONFeatureCard<Artwork: View>: View {
    var width: CGFloat = BONSpacing.cardStackWidth
    let title: String
    @ViewBuilder let artwork: Artwork

    var body: some View {
        HStack(spacing: 12) {
            artwork
                .frame(width: 164, height: 156)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text(title)
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(BONColor.textPrimary)
                .lineSpacing(1)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: textWidth, alignment: .leading)
        }
        .frame(width: innerWidth, height: 156, alignment: .leading)
        .padding(.horizontal, 8)
        .frame(width: width, height: 172)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(BONColor.surfacePrimary)
                .shadow(color: Color.black.opacity(0.07), radius: 20, x: 0, y: 10)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }

    private var innerWidth: CGFloat {
        max(0, width - 16)
    }

    private var textWidth: CGFloat {
        max(120, innerWidth - 164 - 12)
    }
}
