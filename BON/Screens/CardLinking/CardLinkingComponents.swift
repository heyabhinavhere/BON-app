import SwiftUI

// MARK: - Palette

/// Local palette for the card-linking surfaces.
///
/// Kept local instead of promoted to `BONColor` because (a) every value here
/// composes existing `BONColor` tokens, and (b) the three other agents who are
/// concurrently editing the credit / home-animation / budgeting flows share
/// `BONColor`. Touching the shared color file in this branch would create
/// avoidable merge surface.
enum CardLinkingPalette {
    static let canvas = BONColor.backgroundPrimary
    static let textPrimary = BONColor.textPrimary
    static let textSecondary = BONColor.textSecondary
    static let textTertiary = BONColor.textTertiary
    static let benefitChipFill = Color(red: 0.969, green: 0.969, blue: 0.969)
    static let benefitIconHalo = BONColor.lime100
    static let benefitIconStroke = BONColor.lime700
    static let giftHeroBackground = BONColor.lime100
    static let giftHeroAccent = BONColor.lime500
    static let plaidStrokeMuted = Color(red: 0.866, green: 0.866, blue: 0.866)
    static let plaidArrow = Color(red: 0.180, green: 0.180, blue: 0.180)
    static let popupBackdrop = Color.black.opacity(0.36)
    static let popupSurface = Color.white
    static let closeGlyph = Color.black.opacity(0.72)
    static let bankPlaceholderTop = Color(red: 0.10, green: 0.41, blue: 0.34)
    static let bankPlaceholderBottom = Color(red: 0.05, green: 0.18, blue: 0.16)
    static let bankOverlayShadow = Color.black.opacity(0.36)
}

// MARK: - Typography helpers

/// Figma 61:896 uses a 26-ish pt Zalando regular display headline that wraps
/// to two or three lines inside a fixed-height frame. The line height in the
/// Figma export is ~30pt for the 26pt size, with -2% tracking. SwiftUI
/// `.lineSpacing` is the *extra* leading between lines, so for a 26pt size
/// targeting 30pt line height we add 4pt.
private enum CardLinkingType {
    static let displayFont = BONTypography.zalando(size: 26, weight: .regular)
    static let displayTracking: CGFloat = -0.52
    static let displayLineSpacing: CGFloat = 4

    static let compactDisplayFont = BONTypography.zalando(size: 22, weight: .regular)
    static let compactDisplayTracking: CGFloat = -0.44
    static let compactDisplayLineSpacing: CGFloat = 4

    static let popupTitleFont = BONTypography.zalando(size: 18, weight: .medium)
    static let popupTitleTracking: CGFloat = -0.36

    static let chipFont = BONTypography.zalando(size: 14, weight: .regular)
    static let chipTracking: CGFloat = -0.14

    static let bodyFont = BONTypography.zalando(size: 14, weight: .regular)
    static let bodyTracking: CGFloat = -0.14

    static let captionFont = BONTypography.zalando(size: 12, weight: .regular)
    static let captionTracking: CGFloat = -0.12
}

// MARK: - Display headline

struct CardLinkingHeadline: View {
    let text: String
    var alignment: TextAlignment = .leading
    var width: CGFloat? = 272
    var compact: Bool = false

    var body: some View {
        let font: Font = compact ? CardLinkingType.compactDisplayFont : CardLinkingType.displayFont
        let tracking: CGFloat = compact ? CardLinkingType.compactDisplayTracking : CardLinkingType.displayTracking
        let leading: CGFloat = compact ? CardLinkingType.compactDisplayLineSpacing : CardLinkingType.displayLineSpacing

        Text(text)
            .font(font)
            .tracking(tracking)
            .lineSpacing(leading)
            .multilineTextAlignment(alignment)
            .foregroundStyle(CardLinkingPalette.textPrimary)
            .frame(width: width, alignment: alignment == .center ? .center : .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Inline benefit row (used by the popup + the $5 gift screen)

struct CardLinkingBenefitRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(CardLinkingPalette.benefitIconHalo)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(CardLinkingPalette.benefitIconStroke)
            }
            .frame(width: 16, height: 16)
            .accessibilityHidden(true)

            Text(text)
                .font(CardLinkingType.bodyFont)
                .tracking(CardLinkingType.bodyTracking)
                .foregroundStyle(CardLinkingPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.86)

            Spacer(minLength: 0)
        }
        .frame(height: 17)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }
}

// MARK: - Scattered benefit chip (Link credit card hero treatment, Figma Group 48095542)

/// A small white-pilled chip with a soft border + drop shadow used in the
/// scattered benefit cloud on `LinkCreditCardView`. The Figma frame leans on
/// staggered x positions to create a hand-drawn feel; the parent decides the
/// x offset.
struct CardLinkingBenefitChip: View {
    let text: String
    var width: CGFloat?

    var body: some View {
        Text(text)
            .font(CardLinkingType.chipFont)
            .tracking(CardLinkingType.chipTracking)
            .foregroundStyle(CardLinkingPalette.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: BONRadius.lg, style: .continuous)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BONRadius.lg, style: .continuous)
                    .stroke(BONColor.borderSubtle, lineWidth: 1)
            )
            // Figma drop-shadow: blur 32, y 8, opacity 12%. SwiftUI radius = blur / 2 (per the
            // 2026-05-27 lesson on Figma → SwiftUI shadow conversion).
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Plaid trust strip (used by every scenario)

/// Renders the Plaid-trust treatment shared across the four screens. Two
/// variants:
/// * `.full` — used by `LinkCreditCardView` and `LinkBankAccountView`. Two-line
///   header + the BON↔Plaid↔Bank visual + "used by" 4-logo row + footnote.
/// * `.compact` — used by `LinkCreditCardGiftView` and `LinkCreditCardPopup`.
///   Single-line BON↔Plaid↔Bank glyph + 2-line legalese block.
struct CardLinkingPlaidTrust: View {
    enum Variant {
        case full
        case compact
    }

    var variant: Variant = .full

    var body: some View {
        switch variant {
        case .full: full
        case .compact: compact
        }
    }

    // MARK: Full variant

    private var full: some View {
        VStack(spacing: 32) {
            VStack(spacing: 4) {
                Text("We never sell your data.")
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .tracking(CardLinkingType.bodyTracking)
                    .foregroundStyle(CardLinkingPalette.textPrimary)
                Text("BON uses Plaid to securely connect your card.")
                    .font(CardLinkingType.captionFont)
                    .tracking(CardLinkingType.captionTracking)
                    .foregroundStyle(CardLinkingPalette.textSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            PlaidBondedGlyph(size: .large)

            VStack(spacing: 12) {
                Text("used by")
                    .font(CardLinkingType.captionFont)
                    .tracking(CardLinkingType.captionTracking)
                    .foregroundStyle(CardLinkingPalette.textTertiary)
                BankAvatarRow(size: 24, spacing: 12)
                Text("500M+ accounts connected through Plaid.")
                    .font(CardLinkingType.captionFont)
                    .tracking(CardLinkingType.captionTracking)
                    .foregroundStyle(CardLinkingPalette.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Compact variant

    private var compact: some View {
        VStack(spacing: 12) {
            PlaidBondedGlyph(size: .small)
            Text("BON uses Plaid to securely connect your card. 500M+ accounts connected through Plaid.")
                .font(CardLinkingType.captionFont)
                .tracking(CardLinkingType.captionTracking)
                .foregroundStyle(CardLinkingPalette.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: 258)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Plaid bonded glyph (BON wordmark <-> Plaid plug <-> Bank dot)

/// Schematic of "BON connects to Plaid connects to Bank" — a small visual that
/// mirrors the Figma Frame 1410184002. The actual Plaid wordmark and the
/// concrete bank logos must come from the design team; we render a structured
/// placeholder that respects the Figma geometry until those assets ship.
struct PlaidBondedGlyph: View {
    enum Size {
        case large
        case small

        var iconSide: CGFloat {
            switch self {
            case .large: 48
            case .small: 20
            }
        }

        var trackLength: CGFloat {
            switch self {
            case .large: 82
            case .small: 48
            }
        }

        var trackStroke: CGFloat {
            switch self {
            case .large: 1
            case .small: 0.6
            }
        }

        var trackSpacing: CGFloat {
            switch self {
            case .large: 12
            case .small: 8
            }
        }
    }

    var size: Size = .large

    var body: some View {
        HStack(spacing: 4) {
            EndpointIcon(label: "BON", side: size.iconSide)
            ParallelTrack(length: size.trackLength, stroke: size.trackStroke, spacing: size.trackSpacing)
            EndpointIcon(label: "Plaid", side: size.iconSide)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("BON connects securely to Plaid")
    }

    private struct EndpointIcon: View {
        let label: String
        let side: CGFloat

        var body: some View {
            ZStack {
                Circle()
                    .stroke(CardLinkingPalette.plaidStrokeMuted, lineWidth: side >= 32 ? 1 : 0.6)
                Text(label)
                    .font(BONTypography.zalando(size: side >= 32 ? 11 : 7, weight: .medium))
                    .foregroundStyle(CardLinkingPalette.textSecondary)
            }
            .frame(width: side, height: side)
        }
    }

    private struct ParallelTrack: View {
        let length: CGFloat
        let stroke: CGFloat
        let spacing: CGFloat

        var body: some View {
            VStack(spacing: spacing) {
                ForEach(0..<4) { _ in
                    Rectangle()
                        .fill(CardLinkingPalette.plaidStrokeMuted)
                        .frame(width: length, height: stroke)
                }
            }
        }
    }
}

// MARK: - Bank avatar row placeholder

/// Four small circular bank logos in a row. The actual Mastercard / Visa / Amex
/// / Discover style PNGs need to come from the design system; the placeholder
/// renders four monochrome circles with initials so the geometry is preserved.
struct BankAvatarRow: View {
    var size: CGFloat = 24
    var spacing: CGFloat = 12

    private let placeholders: [String] = ["BoA", "C", "Wf", "Cs"]

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(Array(placeholders.enumerated()), id: \.offset) { _, label in
                ZStack {
                    Circle()
                        .fill(BONColor.borderSubtle)
                    Text(label)
                        .font(BONTypography.zalando(size: size * 0.36, weight: .medium))
                        .foregroundStyle(CardLinkingPalette.textTertiary)
                        .minimumScaleFactor(0.5)
                }
                .frame(width: size, height: size)
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Continue button (48pt pill)

/// Local 48pt pill used by every card-linking surface.
///
/// Deliberately *not* `BONPrimaryButton` because that shared button is fixed
/// at 56pt and is currently being edited on `main` by the credit-screen agent.
/// Keeping our 48pt CTA local keeps the merge surface zero.
struct CardLinkingContinueButton: View {
    var title: String = "Continue"
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled, !isLoading else { return }
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.small)
                } else {
                    Text(title)
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .tracking(-0.14)
                        .lineLimit(1)
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
        }
        .buttonStyle(CardLinkingContinueButtonStyle(isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

private struct CardLinkingContinueButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: BONRadius.pill, style: .continuous)
                    .fill(isDisabled ? Color.black.opacity(0.32) : (configuration.isPressed ? BONColor.brandPressed : BONColor.brand))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(BONMotion.press, value: configuration.isPressed)
    }
}

// MARK: - Status bar gap

/// Top of every card-linking full-page screen reserves 54pt for the iOS
/// status bar so the headline does not collide with the system clock. Matches
/// Figma frames 61:898 / 61:991 (54-pt "Status Bar" frame).
struct CardLinkingStatusBarSpacer: View {
    var body: some View {
        Color.clear.frame(height: 54)
    }
}
