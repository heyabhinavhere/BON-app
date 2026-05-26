import SwiftUI

// MARK: - Scenario D — Popup variant of "Link credit card"

/// Scenario D — popup/sheet variant rendered over the AI chat conversation.
///
/// Source of truth: Figma node `61:1041` ("Link credit card pop up"). Layout:
///
/// ```
/// y =  74 … 501  Popup card (342 × 427 with 20-pt radius, slight x = 24 inset)
/// y =  98 … 118  Close (×) glyph in card's top-right
/// y = 117 … 136  "Link credit cards" centered title
/// y = 149 … 313  4 benefit rows (Figma Group 48095542)
/// y = 345 … 393  Continue CTA
/// y = 409 … 477  Compact Plaid trust footer
/// y = 501 … 845  Dimmed chat conversation showing through behind popup
/// ```
///
/// Animation contract: this view is meant to be presented through the
/// `.linkCreditCardPopup(...)` view modifier below, which provides the
/// matched-geometry morph from a host-supplied source element. See the docs
/// on `LinkCreditCardPopupPresenter` for the full Apple-style morph recipe.
struct LinkCreditCardPopupCard: View {
    var onContinue: () -> Void = {}
    var onClose: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Text("Link credit cards")
                    .font(BONTypography.zalando(size: 18, weight: .medium))
                    .tracking(-0.36)
                    .foregroundStyle(CardLinkingPalette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)

                Button {
                    BONHaptics.selection()
                    onClose()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(CardLinkingPalette.closeGlyph)
                        .frame(width: 20, height: 20)
                        .contentShape(Rectangle())
                }
                .padding(.top, 24)
                .padding(.trailing, 20)
                .accessibilityLabel("Close link cards prompt")
            }

            VStack(alignment: .leading, spacing: 14) {
                CardLinkingBenefitRow(text: "Know when your payments are due")
                CardLinkingBenefitRow(text: "See where you’re losing money to interest")
                CardLinkingBenefitRow(text: "Free subscriptions management")
                CardLinkingBenefitRow(text: "Get alerted to charges you don’t recognize")
            }
            .padding(.top, 32)
            .padding(.horizontal, 42)
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                CardLinkingContinueButton(action: onContinue)
                CardLinkingPlaidTrust(variant: .compact)
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(CardLinkingPalette.popupSurface)
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.18), radius: 30, x: 0, y: 18)
        .overlay(alignment: .topLeading) {
            // Invisible accessibility action so VoiceOver users can dismiss.
            Button("Dismiss", role: .cancel) { onClose() }
                .opacity(0)
                .frame(width: 1, height: 1)
                .accessibilityHint("Closes the link cards prompt")
        }
    }
}

#Preview("Popup card — isolated") {
    ZStack {
        Color(white: 0.94).ignoresSafeArea()
        LinkCreditCardPopupCard()
            .frame(width: 342)
            .padding()
    }
}

// MARK: - Apple-style matched-geometry morph

/// Wraps a host content view with the link-credit-card popup overlay and an
/// Apple-style matched-geometry morph from a host-designated source element.
///
/// Recipe summary (mirrors what Apple Photos / App Library / Wallet do):
///
/// 1. The host applies `.linkCreditCardPopupSource(id:in:isActive:)` to the
///    element the popup should grow out of (e.g. a chat message bubble or a
///    CTA pill). The modifier installs a `matchedGeometryEffect` with the
///    given namespace/id and makes it the *source* of the morph as long as
///    the popup is hidden.
/// 2. The host applies `.linkCreditCardPopup(isPresented:source:in:...)`
///    to its outer container. The modifier renders a backdrop and the popup
///    card whenever `isPresented` is true.
/// 3. The popup card carries the same `matchedGeometryEffect(id:in:)`. When
///    `isPresented` flips, SwiftUI interpolates the popup card's geometry
///    from the source element's frame to the natural popup frame using the
///    `BONMotion.matchedMorph` spring (the same matched-morph token already
///    in the BON design system).
/// 4. The backdrop fades in via a separate `.opacity` transition. The card's
///    content cross-fades on top of the morphing background card.
/// 5. The card honours interactive drag-down-to-dismiss with a rubber-band
///    feel that mirrors how `.sheet` behaves on iOS.
///
/// Reduce Motion: falls back to a static cross-fade.
public struct LinkCreditCardPopupPresenter: ViewModifier {
    @Binding var isPresented: Bool
    let sourceID: String
    let namespace: Namespace.ID
    let onContinue: () -> Void
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false

    public func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    if isPresented {
                        backdrop
                            .transition(.opacity)
                            .zIndex(0)

                        popup
                            .zIndex(1)
                    }
                }
                .animation(reduceMotion ? .easeOut(duration: 0.18) : BONMotion.matchedMorph,
                           value: isPresented)
            }
    }

    private var backdrop: some View {
        Group {
            if reduceTransparency {
                CardLinkingPalette.popupBackdrop
            } else {
                ZStack {
                    Color.black
                        .opacity(0.18 * (1 - rubberDragProgress))
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(1 - 0.6 * rubberDragProgress)
                }
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            dismiss()
        }
        .accessibilityHidden(true)
    }

    private var popup: some View {
        VStack(spacing: 0) {
            LinkCreditCardPopupCard(
                onContinue: {
                    onContinue()
                    isPresented = false
                },
                onClose: { dismiss() }
            )
            .frame(maxWidth: 342)
            .padding(.horizontal, BONSpacing.screenHorizontal)
            .padding(.top, 74) // y=74 from Figma 61:1054
            .matchedGeometryEffect(
                id: sourceID,
                in: namespace,
                properties: .frame,
                anchor: .top,
                isSource: isPresented
            )
            // Drag-to-dismiss translation. We rubber-band negative drags
            // (drags upward), so the card can only meaningfully be dragged
            // down, mirroring `.sheet` interaction.
            .offset(y: max(dragOffset, dragOffset * 0.32))
            .scaleEffect(1 - 0.06 * rubberDragProgress, anchor: .top)
            .gesture(dismissDrag, including: reduceMotion ? .subviews : .all)

            Spacer(minLength: 0)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.94, anchor: .top)))
    }

    private var rubberDragProgress: CGFloat {
        let normalized = max(0, min(dragOffset / 220, 1))
        return normalized
    }

    private var dismissDrag: some Gesture {
        DragGesture(minimumDistance: 6)
            .onChanged { value in
                isDragging = true
                dragOffset = value.translation.height
            }
            .onEnded { value in
                isDragging = false
                if value.translation.height > 120 || value.predictedEndTranslation.height > 200 {
                    BONHaptics.impact(.light)
                    withAnimation(BONMotion.matchedMorph) {
                        dragOffset = 0
                        isPresented = false
                    }
                    onDismiss()
                } else {
                    withAnimation(BONMotion.matchedMorph) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismiss() {
        BONHaptics.impact(.light)
        withAnimation(reduceMotion ? .easeOut(duration: 0.18) : BONMotion.matchedMorph) {
            dragOffset = 0
            isPresented = false
        }
        onDismiss()
    }
}

// MARK: - Source modifier

/// Marks a view as the morph source for the credit-card-link popup.
/// Install this on the element that should "grow" into the popup (e.g. a
/// chat bubble, a CTA pill, a list row).
public struct LinkCreditCardPopupSource: ViewModifier {
    let id: String
    let namespace: Namespace.ID
    let isActive: Bool

    public func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(
                id: id,
                in: namespace,
                properties: .frame,
                anchor: .center,
                isSource: isActive
            )
    }
}

// MARK: - View extensions

public extension View {
    /// Marks the receiver as the morph source for the credit-card-link popup.
    /// Pass `isActive: !isPresented` so the source is only authoritative
    /// while the popup is hidden.
    func linkCreditCardPopupSource(id: String, in namespace: Namespace.ID, isActive: Bool) -> some View {
        modifier(LinkCreditCardPopupSource(id: id, namespace: namespace, isActive: isActive))
    }

    /// Presents the credit-card-link popup with an Apple-style matched-geometry
    /// morph from the host-supplied source element. Pair with
    /// `.linkCreditCardPopupSource(id:in:isActive:)` on the source view.
    func linkCreditCardPopup(
        isPresented: Binding<Bool>,
        sourceID: String,
        in namespace: Namespace.ID,
        onContinue: @escaping () -> Void = {},
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        modifier(
            LinkCreditCardPopupPresenter(
                isPresented: isPresented,
                sourceID: sourceID,
                namespace: namespace,
                onContinue: onContinue,
                onDismiss: onDismiss
            )
        )
    }
}

// MARK: - Standalone demo host

/// A self-contained host that demonstrates the morph without any wiring to
/// `RootView`, `AppRouter`, `AIChatView`, or `CreditView`. Used by the
/// `#Preview` below and by `CardLinkingPreviewHost` so simulator QA can
/// capture a clean frame strip of the open / closed states.
struct LinkCreditCardPopupDemo: View {
    @Namespace private var morphNamespace
    @State private var isPresented = false

    var body: some View {
        ZStack {
            FakeChatBackdrop()

            VStack {
                Spacer(minLength: 0)
                Button {
                    withAnimation(BONMotion.matchedMorph) {
                        isPresented = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("Link credit cards")
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                            .tracking(-0.14)
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(BONColor.brand)
                    )
                }
                .linkCreditCardPopupSource(id: "linkCreditCardPopupDemo", in: morphNamespace, isActive: !isPresented)
                .padding(.bottom, 96)
            }
        }
        .linkCreditCardPopup(
            isPresented: $isPresented,
            sourceID: "linkCreditCardPopupDemo",
            in: morphNamespace,
            onContinue: {
                // In production this would route the user into Plaid Link SDK.
            }
        )
    }
}

// MARK: - Auto-open demo (for simulator QA)

/// Auto-opens the popup on appear so simulator captures can show the open
/// state without needing programmatic touch input. Reached via
/// `-BONCardLinking link-credit-card-popup-open`.
struct LinkCreditCardPopupAutoOpenDemo: View {
    @Namespace private var morphNamespace
    @State private var isPresented = false

    var autoOpenDelay: TimeInterval = 0.45

    var body: some View {
        ZStack {
            FakeChatBackdrop()

            VStack {
                Spacer(minLength: 0)
                HStack(spacing: 10) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 14, weight: .medium))
                    Text("Link credit cards")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .tracking(-0.14)
                }
                .foregroundStyle(Color.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background(Capsule().fill(BONColor.brand))
                .linkCreditCardPopupSource(id: "linkCreditCardPopupAutoOpen", in: morphNamespace, isActive: !isPresented)
                .padding(.bottom, 96)
            }
        }
        .linkCreditCardPopup(
            isPresented: $isPresented,
            sourceID: "linkCreditCardPopupAutoOpen",
            in: morphNamespace
        )
        .task {
            try? await Task.sleep(nanoseconds: UInt64(autoOpenDelay * 1_000_000_000))
            withAnimation(BONMotion.matchedMorph) {
                isPresented = true
            }
        }
    }
}

/// Lightweight stand-in for the AI Chat conversation that the Figma frame
/// shows behind the popup. We only need enough visual texture for the morph
/// to read correctly during pixel QA.
private struct FakeChatBackdrop: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Color.clear.frame(height: 54)

            Text("Hey Marcus, here’s what I found:")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary)

            Text("$5250/yr")
                .font(BONTypography.geistPixel(size: 30))
                .foregroundStyle(BONColor.textPrimary)

            Text("going to credit card interest. That’s $14 every single day, gone.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary.opacity(0.84))

            Text("Most of this is fixable. Want me to start with the card costing you the most?")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .foregroundStyle(BONColor.textPrimary.opacity(0.84))

            Capsule()
                .fill(BONColor.borderSubtle)
                .frame(width: 200, height: 38)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, BONSpacing.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(BONColor.canvas.ignoresSafeArea())
    }
}

#Preview("Popup demo with morph") {
    LinkCreditCardPopupDemo()
}
