import SwiftUI
import UIKit

/// The full-bleed AI Chat screen. The home dashboard renders a miniature version
/// of this same surface in its top half (the credit report preview panel). Tapping
/// the panel (or the "Talk with AI" pill) pushes this view onto the navigation
/// stack with `.navigationTransition(.zoom)` so the panel morphs into the full
/// screen — Apple's hero zoom, no extra fades/slides on top.
struct AIChatView: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.dismiss) private var dismiss
    @Namespace private var localNamespace

    private let entryNamespace: Namespace.ID?
    private let sourceID: String

    init(
        entryNamespace: Namespace.ID? = nil,
        sourceID: String = AIChatEntrySource.cta.transitionID,
        usesLaunchArguments: Bool = false
    ) {
        // `usesLaunchArguments` is retained on the API for backward compatibility
        // with QA harness launch flows. The new cards-based chat has no
        // typing/thinking/response phases of its own; the initial scroll position
        // is still honored via `HomeFirstTimerLaunch.reportScrollOffset` inside
        // `FirstTimerAIReportView`.
        _ = usesLaunchArguments
        self.entryNamespace = entryNamespace
        self.sourceID = sourceID
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = HomeFirstTimerMetrics(
                size: proxy.size,
                safeArea: proxy.safeAreaInsets
            )
            // The view ignores all safe areas, so `proxy.safeAreaInsets`
            // returns zero on all edges. To position the composer correctly
            // above the home indicator we read `UIWindow`'s safe area
            // directly via UIKit (set once at scene load and stable for the
            // lifetime of the destination view).
            let bottomSafeInset = AIChatSafeArea.bottomInset()
            let composerBottomPadding: CGFloat = bottomSafeInset > 0 ? bottomSafeInset + 14 : 28
            let composerReservedSpace: CGFloat = 64 + composerBottomPadding

            ZStack {
                BONColor.backgroundPrimary
                    .ignoresSafeArea()

                // Lime Siri-style edge glow sits *behind* the chat content.
                // FirstTimerAIReportView no longer paints an opaque white
                // chassis, so this glow is visible along the screen edges
                // wherever no card is covering it — same layering as the
                // legacy AIChatView, just with the new cards-based content.
                BONSiriEdgeGlow(isActive: !reduceTransparency)
                    .opacity(reduceTransparency ? 0 : 0.88)
                    .ignoresSafeArea()

                FirstTimerAIReportView(
                    metrics: metrics,
                    namespace: localNamespace,
                    aiEntryNamespace: nil,
                    isActiveAITransitionSource: false,
                    scrollBottomReserved: composerReservedSpace,
                    onHome: { dismiss() },
                    onAskAI: {}
                )

                // Fixed bottom composer overlaid on the chat surface. We pin
                // it manually (no `safeAreaInset`) because the inner
                // GeometryReader + explicit frame combination doesn't
                // propagate the inset to the scroll content otherwise — the
                // explicit `scrollBottomReserved` padding handles that.
                //
                // A linear fade-to-white gradient sits behind the composer
                // (and extends past its bottom edge, ignoring the safe area)
                // so any scroll content that slides under it dissolves
                // smoothly into the chrome rather than peeking out around
                // the capsule's rounded sides — same pattern as Apple's
                // translucent tab bars.
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    ZStack(alignment: .bottom) {
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0), location: 0.0),
                                .init(color: Color.white.opacity(0.70), location: 0.32),
                                .init(color: Color.white.opacity(0.96), location: 0.62),
                                .init(color: Color.white, location: 0.85),
                                .init(color: Color.white, location: 1.0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 140 + composerBottomPadding + 48)
                        .ignoresSafeArea(edges: .bottom)
                        .allowsHitTesting(false)

                        FirstTimerChatComposer(
                            width: metrics.reportContentWidth,
                            placeholder: "Ask BON Credit...",
                            action: {}
                        )
                        .padding(.bottom, composerBottomPadding)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea()
        .modifier(AIChatZoomTransitionModifier(entryNamespace: entryNamespace, sourceID: sourceID))
    }
}

/// Reads the active window's bottom safe-area inset (home indicator height).
/// We need this because the AIChatView ignores all safe areas to make its
/// background and edge glow extend to the screen edges, which zeroes out
/// `GeometryProxy.safeAreaInsets` for SwiftUI's view tree.
private enum AIChatSafeArea {
    static func bottomInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        for scene in scenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            if let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first {
                return window.safeAreaInsets.bottom
            }
        }
        return 0
    }
}

/// Applies the Apple `.navigationTransition(.zoom)` only when an entry namespace
/// is supplied. Direct launches (e.g. `-BONInitialRoute ai-chat`) without a
/// matched source fall through to the system's default push.
private struct AIChatZoomTransitionModifier: ViewModifier {
    let entryNamespace: Namespace.ID?
    let sourceID: String

    func body(content: Content) -> some View {
        if let entryNamespace {
            content.navigationTransition(.zoom(sourceID: sourceID, in: entryNamespace))
        } else {
            content
        }
    }
}

// MARK: - Shared chrome surfaces
//
// These surfaces are also used by the home dashboard preview to keep the
// miniature panel pixel-identical to the full chat screen. They live here
// because the chat screen is their canonical home.

struct AIChatTopScrim: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color.white.opacity(0.995), location: 0.0),
                .init(color: Color.white.opacity(0.98), location: 0.58),
                .init(color: Color.white.opacity(0.0), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 150)
        .blur(radius: reduceTransparency ? 0 : 1)
    }
}

struct BONChatTopIconControl: View {
    private let systemName: String?
    private let imageAsset: String?
    private let iconSize: CGFloat

    init(systemName: String, iconSize: CGFloat = 16) {
        self.systemName = systemName
        self.imageAsset = nil
        self.iconSize = iconSize
    }

    init(imageAsset: String, iconSize: CGFloat = 16) {
        self.systemName = nil
        self.imageAsset = imageAsset
        self.iconSize = iconSize
    }

    var body: some View {
        BONChatTopIconSurface()
            .overlay {
                icon
            }
            .frame(width: 40, height: 40)
            .contentShape(Circle())
    }

    @ViewBuilder
    private var icon: some View {
        if let imageAsset {
            Image(imageAsset)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(BONColor.textPrimary)
                .frame(width: iconSize, height: iconSize)
        } else if let systemName {
            Image(systemName: systemName)
                .font(.system(size: iconSize, weight: .medium))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(BONColor.textPrimary)
        }
    }
}

private struct BONChatTopIconSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let circle = Circle()

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                circle
                    .fill(Color.white.opacity(0.035))

                circle
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.34),
                                Color.white.opacity(0.07),
                                Color.white.opacity(0.01)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 48
                        )
                    )
                    .blendMode(.screen)

                circle
                    .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.7)
                    .blur(radius: 0.35)
                    .opacity(0.44)
            }
            .clipShape(circle)
            .glassEffect(.regular.tint(Color.white.opacity(0.18)).interactive(), in: circle)
            .shadow(color: Color.black.opacity(0.04), radius: 15, x: 0, y: 8)
            .shadow(color: BONColor.limeGlow.opacity(0.08), radius: 20, x: 0, y: 0)
        } else {
            circle
                .fill(reduceTransparency ? Color.white : Color.white.opacity(0.76))
                .overlay(
                    circle
                        .strokeBorder(Color.white.opacity(0.72), lineWidth: 0.8)
                )
                .shadow(color: Color.black.opacity(0.055), radius: 18, x: 0, y: 8)
        }
    }
}

struct BONChatExpertPillSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.82), location: 0.0),
                                .init(color: Color.black.opacity(0.70), location: 0.55),
                                .init(color: Color.black.opacity(0.80), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                capsule
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.24),
                                Color.white.opacity(0.04),
                                Color.black.opacity(0.20)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .blendMode(.softLight)

                capsule
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                    .blur(radius: 0.35)
                    .opacity(0.58)
            }
            .clipShape(capsule)
            .glassEffect(.regular.tint(Color.black.opacity(0.74)).interactive(), in: capsule)
            .shadow(color: Color.black.opacity(0.19), radius: 11, x: 0, y: 8)
            .shadow(color: Color.black.opacity(0.075), radius: 22, x: 0, y: 16)
        } else {
            capsule
                .fill(Color.black.opacity(reduceTransparency ? 0.88 : 0.82))
                .overlay(
                    capsule
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .shadow(color: Color.black.opacity(0.22), radius: 12, x: 0, y: 8)
        }
    }
}

struct BONChatComposerActionSurface: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        if #available(iOS 26.0, *), !reduceTransparency {
            ZStack {
                capsule
                    .fill(Color.black.opacity(0.30))
                    .glassEffect(.regular.tint(Color.black.opacity(0.56)).interactive(), in: capsule)

                capsule
                    .fill(Color(red: 0.285, green: 0.285, blue: 0.275).opacity(0.94))

                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.white.opacity(0.10), location: 0.0),
                                .init(color: Color.white.opacity(0.045), location: 0.34),
                                .init(color: Color.black.opacity(0.20), location: 1.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.softLight)

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.055),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 58
                        )
                    )
                    .blendMode(.screen)

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.18),
                                Color.black.opacity(0.055),
                                Color.clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 74
                        )
                    )
                    .blendMode(.multiply)
            }
            .clipShape(capsule)
            .shadow(color: Color.black.opacity(0.25), radius: 8, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.13), radius: 18, x: 0, y: 10)
        } else {
            ZStack {
                capsule
                    .fill(Color(red: 0.25, green: 0.25, blue: 0.24).opacity(reduceTransparency ? 0.96 : 0.90))

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.09),
                                Color.white.opacity(0.025),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 58
                        )
                    )

                capsule
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.black.opacity(0.24),
                                Color.black.opacity(0.08),
                                Color.clear
                            ],
                            center: .bottomTrailing,
                            startRadius: 0,
                            endRadius: 74
                        )
                    )
            }
            .clipShape(capsule)
            .shadow(color: Color.black.opacity(0.28), radius: 8, x: 0, y: 5)
            .shadow(color: Color.black.opacity(0.16), radius: 18, x: 0, y: 10)
        }
    }
}

struct BONChatGlassCapsule: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        let capsule = Capsule(style: .continuous)

        let surface = ZStack {
            if reduceTransparency {
                capsule.fill(Color.black.opacity(0.90))
            } else {
                if #available(iOS 26.0, *) {
                    capsule
                        .fill(Color.black.opacity(0.46))
                        .glassEffect(.regular.tint(Color.black.opacity(0.82)).interactive(), in: capsule)
                } else {
                    capsule.fill(.ultraThinMaterial)
                }

                capsule
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: Color.black.opacity(0.92), location: 0.0),
                                .init(color: Color.black.opacity(0.82), location: 0.52),
                                .init(color: Color.black.opacity(0.91), location: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            capsule
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.090),
                            Color.clear,
                            Color.black.opacity(0.24)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.softLight)

            capsule
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color.clear, location: 0.18),
                            .init(color: Color.white.opacity(0.050), location: 0.48),
                            .init(color: Color.clear, location: 0.70)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .blendMode(.screen)

            capsule
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.025),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 112
                    )
                )
                .blendMode(.screen)

            capsule
                .fill(
                    RadialGradient(
                        colors: [
                            Color.black.opacity(0.22),
                            Color.black.opacity(0.08),
                            Color.clear
                        ],
                        center: .trailing,
                        startRadius: 12,
                        endRadius: 126
                    )
                )
                .blendMode(.multiply)
        }
        .clipShape(capsule)

        if #available(iOS 26.0, *), !reduceTransparency {
            surface
                .shadow(color: Color.black.opacity(0.20), radius: 14, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.11), radius: 30, x: 0, y: 24)
        } else {
            surface
                .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: 12)
                .shadow(color: Color.black.opacity(0.10), radius: 28, x: 0, y: 24)
        }
    }
}

struct BONSiriEdgeGlow: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: Double = 0

    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            let cornerRadius = min(58, max(42, proxy.size.width * 0.12))
            let animatedGradient = AngularGradient(
                colors: [
                    BONColor.lime50.opacity(0.18),
                    BONColor.lime100.opacity(0.52),
                    BONColor.lime200.opacity(0.78),
                    BONColor.lime300.opacity(0.68),
                    BONColor.lime100.opacity(0.42),
                    BONColor.lime50.opacity(0.18)
                ],
                center: .center,
                angle: .degrees(phase)
            )

            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(animatedGradient, lineWidth: 2.4)
                    .blur(radius: 5.5)
                    .padding(7)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(animatedGradient, lineWidth: 1.1)
                    .blur(radius: 11)
                    .padding(1)
                    .opacity(0.72)

                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [
                            BONColor.lime300.opacity(0.18),
                            BONColor.lime200.opacity(0.14),
                            BONColor.lime100.opacity(0.08),
                            BONColor.lime50.opacity(0.03),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 18)

                    Spacer(minLength: 0)

                    LinearGradient(
                        colors: [
                            .clear,
                            BONColor.lime50.opacity(0.03),
                            BONColor.lime100.opacity(0.08),
                            BONColor.lime200.opacity(0.14),
                            BONColor.lime300.opacity(0.18)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 18)
                }
                .blur(radius: 9)
            }
            .scaleEffect(isActive && !reduceMotion ? 1.006 : 1)
            .animation(reduceMotion ? nil : .easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isActive)
        }
        .allowsHitTesting(false)
        .onAppear {
            guard !reduceMotion else {
                return
            }

            withAnimation(.linear(duration: 5.4).repeatForever(autoreverses: false)) {
                phase = 360
            }
        }
    }
}

#Preview {
    AIChatView()
}
