import SwiftUI

/// Scenario A — generic credit-card linking surface.
///
/// Source of truth: Figma node `61:897` ("Link credit card").
///
/// Layout follows the Figma frame measurements directly:
///
/// ```
/// y =   0 …  54  Status bar
/// y =  86 … 146  Headline ("Unlock personalized and maximum savings")
/// y = 185 … 391  Scattered benefit chips (Figma Group 48095542)
/// y = 461 … 701  Plaid trust treatment
/// y = 749 … 797  Continue CTA
/// ```
struct LinkCreditCardView: View {
    var onContinue: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            CardLinkingPalette.canvas.ignoresSafeArea()

            VStack(spacing: 0) {
                CardLinkingStatusBarSpacer()

                // Optional close affordance — Figma doesn't draw one on this frame,
                // but iOS users expect a way out. We render an invisible 32pt slot
                // so the headline alignment matches Figma, and only show the close
                // glyph when a host explicitly hands us an `onClose`.
                ZStack(alignment: .topLeading) {
                    Color.clear.frame(height: 32)
                    Button {
                        BONHaptics.selection()
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(CardLinkingPalette.closeGlyph)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                    }
                    .opacity(0.0)
                }
                .padding(.horizontal, BONSpacing.screenHorizontal)

                Spacer().frame(height: 0)

                CardLinkingHeadline(
                    text: "Unlock personalized and maximum savings",
                    alignment: .leading,
                    width: 272,
                    compact: false
                )
                .padding(.leading, 41 + 18) // Figma 61:908 (41) + 61:909 internal padding (18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)

                ScatteredBenefitsCloud()
                    .padding(.top, 39)
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                VStack(spacing: 32) {
                    CardLinkingPlaidTrust(variant: .full)
                    CardLinkingContinueButton(action: onContinue)
                }
                .padding(.horizontal, BONSpacing.screenHorizontal)
                .padding(.bottom, 48)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Scattered benefit cloud (Figma Group 48095542)

/// Renders the four short benefit lines as staggered chips. Figma puts them
/// inside a `325.69 × 206.30` bounding box at y=185 with hand-feel offsets:
///
/// * "Know when your payments are due" — top-right cluster
/// * "See where you're losing money to interest" — wide chip pulled left
/// * "Get alerted to charges you don't recognize" — center chip pushed right
/// * "Get 0% Balance transfer card offers" — bottom chip pulled left
private struct ScatteredBenefitsCloud: View {
    private struct Chip: Identifiable {
        let id = UUID()
        let text: String
        let width: CGFloat
        let xOffset: CGFloat
        let yOffset: CGFloat
    }

    private let chips: [Chip] = [
        Chip(text: "Know when your payments are due", width: 262, xOffset: 22, yOffset: 0),
        Chip(text: "See where you’re losing money to interest", width: 304, xOffset: 2, yOffset: 60),
        Chip(text: "Get alerted to charges you don’t recognize", width: 310, xOffset: 12, yOffset: 120),
        Chip(text: "Get 0% Balance transfer card offers", width: 268, xOffset: -2, yOffset: 156)
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 326, height: 220)

            ForEach(chips) { chip in
                CardLinkingBenefitChip(text: chip.text, width: chip.width)
                    .offset(x: chip.xOffset, y: chip.yOffset)
            }
        }
        .frame(width: 326, height: 220)
        .accessibilityElement(children: .contain)
    }
}

#Preview("Scenario A — Link credit card") {
    LinkCreditCardView()
}
