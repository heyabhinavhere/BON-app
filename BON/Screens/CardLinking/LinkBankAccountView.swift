import SwiftUI

/// Scenario C — link bank account.
///
/// Source of truth: Figma node `61:989` ("Link bank account").
///
/// This screen is dominated by a full-bleed brand illustration (Figma image
/// `1930`) that extends past the top and right edges of the safe area. A
/// gradient overlay (Figma rectangle `40238`) fades the bottom of the
/// illustration into the legal copy + Continue CTA stack.
///
/// ```
/// y =   0 …  54  Status bar
/// y =  86 … 146  Headline ("Know exactly where your money goes")
/// y = 178 … 896  Full-bleed illustration (`image 1930`, placeholder)
/// y = 574 … 888  Bottom gradient overlay (Figma rectangle 40238)
/// y = 661 … 697  "BON uses Plaid to securely connect your bank." +
///                "500M+ accounts connected through Plaid."
/// y = 721 … 737  "used by:" row with four bank avatars
/// y = 749 … 797  Continue CTA
/// ```
struct LinkBankAccountView: View {
    var onContinue: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {
            CardLinkingPalette.canvas.ignoresSafeArea()

            // Full-bleed illustration sits behind everything.
            BankIllustrationPlaceholder()
                .ignoresSafeArea()

            // Bottom gradient overlay that fades the illustration into the
            // legalese stack so text stays legible.
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                LinearGradient(
                    colors: [
                        CardLinkingPalette.canvas.opacity(0.0),
                        CardLinkingPalette.canvas.opacity(0.86),
                        CardLinkingPalette.canvas.opacity(1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 314)
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                CardLinkingStatusBarSpacer()

                CardLinkingHeadline(
                    text: "Know exactly where your money goes",
                    alignment: .leading,
                    width: 272,
                    compact: false
                )
                .padding(.leading, 41 + 18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 16)

                Spacer(minLength: 0)

                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Text("BON uses Plaid to securely connect your bank.")
                            .font(BONTypography.zalando(size: 12, weight: .regular))
                            .tracking(-0.12)
                            .foregroundStyle(CardLinkingPalette.textSecondary)
                        Text("500M+ accounts connected through Plaid.")
                            .font(BONTypography.zalando(size: 12, weight: .regular))
                            .tracking(-0.12)
                            .foregroundStyle(CardLinkingPalette.textSecondary)
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                    HStack(spacing: 16) {
                        Text("used by:")
                            .font(BONTypography.zalando(size: 12, weight: .regular))
                            .tracking(-0.12)
                            .foregroundStyle(CardLinkingPalette.textTertiary)
                        Spacer(minLength: 0)
                        BankAvatarRow(size: 16, spacing: 12)
                    }

                    CardLinkingContinueButton(action: onContinue)
                }
                .padding(.horizontal, BONSpacing.screenHorizontal)
                .padding(.bottom, 48)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Bank illustration placeholder (Figma image 1930)

/// The hero illustration for the bank-linking screen is currently a stylised
/// dark-emerald gradient with abstract banking shapes — kept entirely in
/// SwiftUI so the screen looks intentional in QA before the production
/// `cardLinkingBankHero` PNG is exported from Figma. The placeholder honours
/// the Figma frame's full-bleed footprint and the `-33, 178, 455, 718`
/// bleed offsets so swapping in the real asset is a one-line change.
private struct BankIllustrationPlaceholder: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    CardLinkingPalette.bankPlaceholderTop,
                    CardLinkingPalette.bankPlaceholderBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            BankIllustrationShapes()
                .opacity(0.30)

            // Inner specular highlight along the top edge so the illustration
            // reads as glass-rendered rather than flat paint.
            LinearGradient(
                colors: [Color.white.opacity(0.18), .clear],
                startPoint: .top,
                endPoint: .center
            )
        }
    }
}

private struct BankIllustrationShapes: View {
    var body: some View {
        Canvas { context, size in
            // Large soft circle bottom-right (vault).
            let vault = Path(ellipseIn: CGRect(
                x: size.width * 0.42,
                y: size.height * 0.42,
                width: size.width * 0.78,
                height: size.width * 0.78
            ))
            context.fill(vault, with: .color(Color.white.opacity(0.18)))

            // Coin stack mid-left.
            for index in 0..<5 {
                let coin = Path(ellipseIn: CGRect(
                    x: size.width * 0.12,
                    y: size.height * 0.55 + CGFloat(index) * 14,
                    width: 96,
                    height: 18
                ))
                context.fill(coin, with: .color(Color.white.opacity(0.22 + Double(index) * 0.04)))
            }

            // Card mid-top.
            let card = Path(roundedRect: CGRect(
                x: size.width * 0.18,
                y: size.height * 0.28,
                width: 168,
                height: 104
            ), cornerRadius: 18)
            context.fill(card, with: .color(Color.white.opacity(0.22)))
            context.stroke(card, with: .color(Color.white.opacity(0.36)), lineWidth: 1.2)

            // Card stripe.
            let stripe = Path(roundedRect: CGRect(
                x: size.width * 0.18 + 16,
                y: size.height * 0.28 + 60,
                width: 70,
                height: 10
            ), cornerRadius: 4)
            context.fill(stripe, with: .color(Color.white.opacity(0.62)))
        }
    }
}

#Preview("Scenario C — Link bank account") {
    LinkBankAccountView()
}
