import SwiftUI

/// Scenario B — $5 gift-card incentive variant.
///
/// Source of truth: Figma node `61:942` ("Link credit card & get $5").
///
/// Layout:
///
/// ```
/// y =   0 …  54  Status bar
/// y = 102 … 128  "Get $5 gift card" (centered)
/// y = 144 … 336  Gift-card hero image (300 × 192)
/// y = 354 … 380  "for each credit card linked" (centered subtitle)
/// y = 479 … 589  "Card linking lets you:" + 3 benefit rows
/// y = 665 … 713  Continue CTA
/// y = 733 … 801  Compact Plaid trust footer
/// ```
struct LinkCreditCardGiftView: View {
    var onContinue: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            CardLinkingPalette.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                CardLinkingStatusBarSpacer()

                GiftHeroBlock()
                    .padding(.horizontal, 45)
                    .padding(.top, 48)

                Spacer(minLength: 0)

                BenefitsBlock()
                    .padding(.horizontal, 33)

                Spacer(minLength: 0)

                VStack(spacing: 20) {
                    CardLinkingContinueButton(action: onContinue)
                    CardLinkingPlaidTrust(variant: .compact)
                }
                .padding(.horizontal, BONSpacing.screenHorizontal)
                .padding(.bottom, 44)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Hero block

/// The gift-card visual is currently a structured placeholder because the
/// production hero PNG (Figma image 1939) has not been exported yet. The
/// placeholder respects the exact 300 × 192 frame and lays out a "5" wordmark,
/// a "gift card" caption, and four bank-icon dots so the visual weight closely
/// matches the Figma. The integrator should swap the inner content for the
/// real `Image("cardLinkingGiftHero")` once the asset is added to the catalog.
private struct GiftHeroBlock: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Get $5 gift card")
                .font(BONTypography.zalando(size: 22, weight: .medium))
                .tracking(-0.44)
                .foregroundStyle(CardLinkingPalette.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)

            GiftHeroPlaceholder()
                .frame(width: 300, height: 192)

            Text("for each credit card linked")
                .font(BONTypography.zalando(size: 18, weight: .regular))
                .tracking(-0.36)
                .foregroundStyle(CardLinkingPalette.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 300)
        .frame(maxWidth: .infinity)
    }
}

private struct GiftHeroPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BONColor.lime100, BONColor.lime300.opacity(0.88), BONColor.lime500.opacity(0.42)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.72), lineWidth: 1)

            VStack(spacing: 6) {
                Text("$5")
                    .font(BONTypography.zalando(size: 56, weight: .bold))
                    .tracking(-1.0)
                    .foregroundStyle(CardLinkingPalette.textPrimary)

                Text("GIFT CARD")
                    .font(BONTypography.zalando(size: 12, weight: .medium))
                    .tracking(2.4)
                    .foregroundStyle(CardLinkingPalette.textSecondary)
            }
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.12), radius: 14, x: 0, y: 8)
    }
}

// MARK: - Benefits block (Figma Frame 1410184619)

private struct BenefitsBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Card linking lets you:")
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .tracking(-0.14)
                .foregroundStyle(CardLinkingPalette.textTertiary)

            VStack(alignment: .leading, spacing: 12) {
                CardLinkingBenefitRow(text: "Know when your payments are due")
                CardLinkingBenefitRow(text: "Get alerted to charges you don’t recognize")
                CardLinkingBenefitRow(text: "See where you’re losing money to interest")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Scenario B — Link credit card & get $5") {
    LinkCreditCardGiftView()
}
