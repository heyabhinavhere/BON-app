import SwiftUI

struct BONPrimaryButton: View {
    let title: String
    var systemImage: String?
    var isLoading = false
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled, !isLoading else { return }
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            HStack(spacing: BONSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .controlSize(.small)
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(BONTypography.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BONPrimaryButtonStyle(isDisabled: isDisabled || isLoading))
        .disabled(isDisabled || isLoading)
        .accessibilityLabel(title)
    }
}

struct BONIntentCTA: View {
    let title: String
    var revealProgress: CGFloat = 1
    var theme: BONIntentCTATheme = .lime
    var horizontalPadding: CGFloat = 24
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button {
            guard !isDisabled else { return }
            Task { @MainActor in
                BONHaptics.impact(.light)
                action()
            }
        } label: {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .medium))
                .foregroundStyle(theme.foregroundColor(isDisabled: isDisabled))
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(BONIntentCTAStyle(
            revealProgress: revealProgress,
            theme: theme,
            horizontalPadding: horizontalPadding,
            isDisabled: isDisabled
        ))
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
}

enum BONIntentCTATheme: Equatable {
    case lime
    case dark

    func foregroundColor(isDisabled: Bool) -> Color {
        switch self {
        case .lime:
            return BONColor.textPrimary.opacity(isDisabled ? 0.52 : 1)
        case .dark:
            return Color.white.opacity(isDisabled ? 0.52 : 1)
        }
    }

    func baseFill(isDisabled: Bool) -> Color {
        switch self {
        case .lime:
            return isDisabled ? BONColor.lime100.opacity(0.42) : BONColor.lime500
        case .dark:
            return isDisabled
                ? Color(red: 16 / 255, green: 17 / 255, blue: 24 / 255).opacity(0.42)
                : Color(red: 16 / 255, green: 17 / 255, blue: 24 / 255)
        }
    }

    // Lime-only: top fill linear sheen
    func limeTopFillColors() -> [Color] {
        [
            BONColor.lime50.opacity(0.46),
            BONColor.lime200.opacity(0.22),
            BONColor.lime500.opacity(0.0)
        ]
    }

    // Lime-only: stroke colors
    func limeBorderColor(isDisabled: Bool) -> Color {
        Color.black.opacity(isDisabled ? 0.18 : 0.92)
    }

    // Lime-only: brand glow shadow.
    // Figma reference 61:7641 ("Start chat" lime CTA) renders as a clean solid lime pill with
    // no external halo glow — so the resting/pressed glow opacities are zero. The depth shadow
    // on `BONIntentCTAStyleBody` still gives subtle elevation; the lime caustic shimmer still
    // animates inside the pill. To re-enable the halo on a specific surface in future, raise
    // these opacities (`0.20` rest / `0.14` press gives a noticeable but restrained halo).
    var limeGlowColor: Color { BONColor.lime300 }
    var limeRestingGlowOpacity: Double { 0.0 }
    var limePressedGlowOpacity: Double { 0.0 }
}

private struct BONPrimaryButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .padding(.horizontal, BONSpacing.lg)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: BONRadius.pill, style: .continuous)
                    .fill(isDisabled ? BONColor.tertiaryInk : (configuration.isPressed ? BONColor.brandPressed : BONColor.brand))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(BONMotion.press, value: configuration.isPressed)
    }
}

private struct BONIntentCTAStyle: ButtonStyle {
    var revealProgress: CGFloat
    var theme: BONIntentCTATheme
    var horizontalPadding: CGFloat
    var isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        BONIntentCTAStyleBody(
            label: configuration.label,
            isPressed: configuration.isPressed,
            revealProgress: revealProgress,
            theme: theme,
            horizontalPadding: horizontalPadding,
            isDisabled: isDisabled
        )
    }
}

private struct BONIntentCTAStyleBody<Label: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @State private var didResolve = false

    let label: Label
    let isPressed: Bool
    let revealProgress: CGFloat
    let theme: BONIntentCTATheme
    let horizontalPadding: CGFloat
    let isDisabled: Bool

    private var resolvedReveal: CGFloat {
        min(1, max(0, revealProgress))
    }

    private var readyProgress: CGFloat {
        reduceMotion ? 1 : (didResolve ? 1 : 0)
    }

    private var activeDepth: CGFloat {
        guard !isDisabled else { return 0 }
        return max(resolvedReveal, readyProgress)
    }

    var body: some View {
        TimelineView(.animation(paused: reduceMotion || reduceTransparency || isDisabled)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate

            label
                .padding(.horizontal, horizontalPadding)
                .background {
                    BONIntentCTASurface(
                        phase: phase,
                        revealProgress: resolvedReveal,
                        readyProgress: readyProgress,
                        theme: theme,
                        isPressed: isPressed,
                        isDisabled: isDisabled,
                        reduceMotion: reduceMotion,
                        reduceTransparency: reduceTransparency
                    )
                }
                .scaleEffect(reduceMotion ? 1 : (isPressed ? 0.985 : bonIntentLerp(0.992, 1.0, readyProgress)))
                .shadow(
                    color: depthShadowColor,
                    radius: depthShadowRadius,
                    x: 0,
                    y: depthShadowY
                )
                .shadow(
                    color: brandGlowShadowColor,
                    radius: brandGlowShadowRadius,
                    x: 0,
                    y: brandGlowShadowY
                )
                .animation(reduceMotion ? nil : .spring(response: 0.24, dampingFraction: 0.86), value: isPressed)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: didResolve)
        }
        .onAppear {
            guard !reduceMotion else {
                didResolve = true
                return
            }

            didResolve = false
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 90_000_000)
                withAnimation(.spring(response: 0.36, dampingFraction: 0.88)) {
                    didResolve = true
                }
            }
        }
    }

    private var depthShadowColor: Color {
        let factor: Double = theme == .dark ? 0.18 : 0.10
        return Color.black.opacity(reduceTransparency ? factor * 0.7 : factor * Double(activeDepth))
    }

    private var depthShadowRadius: CGFloat {
        theme == .dark ? (isPressed ? 8 : 18) : (isPressed ? 8 : 14)
    }

    private var depthShadowY: CGFloat {
        theme == .dark ? (isPressed ? 3 : 10) : (isPressed ? 3 : 8)
    }

    // Lime brand glow shadow — second shadow layer only used for lime. Dark relies on the inner wave for glow.
    private var brandGlowShadowColor: Color {
        guard theme == .lime, !reduceTransparency else { return .clear }
        let opacity = (isPressed ? theme.limePressedGlowOpacity : theme.limeRestingGlowOpacity) * Double(activeDepth)
        return theme.limeGlowColor.opacity(opacity)
    }

    private var brandGlowShadowRadius: CGFloat { isPressed ? 10 : 22 }
    private var brandGlowShadowY: CGFloat { isPressed ? 4 : 10 }
}

private struct BONIntentCTASurface: View {
    let phase: TimeInterval
    let revealProgress: CGFloat
    let readyProgress: CGFloat
    let theme: BONIntentCTATheme
    let isPressed: Bool
    let isDisabled: Bool
    let reduceMotion: Bool
    let reduceTransparency: Bool

    private var activeProgress: CGFloat {
        isDisabled ? 0 : max(revealProgress, readyProgress)
    }

    var body: some View {
        GeometryReader { proxy in
            let capsule = Capsule(style: .continuous)
            let baseFill = theme.baseFill(isDisabled: isDisabled)

            ZStack {
                capsule.fill(baseFill)

                if !reduceTransparency {
                    if theme == .dark {
                        // Inner violet wave is parked while we evaluate the bead alone.
                        // To restore: insert `BONDarkIntentGradientWave(...)` here above the border light.
                        BONDarkIntentBorderLight(
                            phase: phase,
                            activeProgress: activeProgress,
                            isPressed: isPressed,
                            isActive: !reduceMotion && !isDisabled
                        )
                    } else {
                        // Lime path — unchanged: linear top sheen + caustic shimmer
                        capsule
                            .fill(
                                LinearGradient(
                                    colors: theme.limeTopFillColors(),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(0.72 * activeProgress)

                        BONIntentCTACaustic(
                            phase: phase,
                            isPressed: isPressed,
                            isActive: !reduceMotion && !isDisabled && revealProgress > 0.72
                        )
                        .opacity(activeProgress)
                    }
                }

                // Lime keeps its dark stroke + specular border (unchanged)
                if theme == .lime {
                    capsule.stroke(theme.limeBorderColor(isDisabled: isDisabled), lineWidth: isPressed ? 1.15 : 1.0)

                    capsule
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(reduceTransparency ? 0.22 : 0.52),
                                    Color.white.opacity(0.08),
                                    Color.black.opacity(0.18)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .opacity(isDisabled ? 0.18 : 0.82)
                }

                // Press flash — soft top-right highlight on tap for tactile feedback
                if !reduceTransparency {
                    let pressCore: Double = theme == .dark ? 0.22 : 0.32
                    let pressAccent: Double = theme == .dark ? 0.14 : 0.20
                    let pressAccentColor: Color = theme == .dark ? BONColor.lime100 : Color.white

                    RadialGradient(
                        colors: [
                            Color.white.opacity(isPressed ? pressCore : 0.0),
                            pressAccentColor.opacity(isPressed ? pressAccent : 0.0),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.72, y: 0.46),
                        startRadius: 2,
                        endRadius: max(proxy.size.width, proxy.size.height) * 0.54
                    )
                    .scaleEffect(isPressed ? 1.16 : 0.58, anchor: .center)
                    .opacity(isPressed ? 1 : 0)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: isPressed)
                }
            }
            .clipShape(capsule)
        }
    }
}

// MARK: - Dark CTA: violet→indigo gradient wave (PARKED — not wired into BONIntentCTASurface)
// Kept here so the recipe (drifting violet bloom + indigo wash + lavender peak + brand-lime peak)
// can be restored with a single line in BONIntentCTASurface if we decide to bring it back.

private struct BONDarkIntentGradientWave: View {
    let phase: TimeInterval
    let activeProgress: CGFloat
    let isPressed: Bool
    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            // Slow horizontal drift of the main bloom (~ 5.4s orbit)
            let driftPhase = isActive ? sin(phase * 2 * .pi / 5.4) : 0.0
            let centerX = 0.5 + CGFloat(driftPhase) * 0.22

            // Bloom breathes (~ 3.8s cycle)
            let bloomRaw = isActive ? (0.5 - 0.5 * cos(phase * 2 * .pi / 3.8)) : 0.6
            let bloom = 0.45 + 0.55 * bloomRaw   // 0.45 … 1.0

            // Secondary indigo wash drifts independently for organic depth
            let secondaryRaw = isActive ? (0.5 - 0.5 * cos((phase + 1.7) * 2 * .pi / 6.2)) : 0.5
            let secondaryDrift = isActive ? cos(phase * 2 * .pi / 7.6) : 0.0
            let secondaryX = 0.5 + CGFloat(secondaryDrift) * 0.32

            let pressBoost: CGFloat = isPressed ? 1.18 : 1.0
            let mainRadius = bonIntentLerp(height * 1.1, height * 1.7, CGFloat(bloom)) * pressBoost

            let violet = Color(red: 0.55, green: 0.40, blue: 1.00)
            let lavender = Color(red: 0.72, green: 0.59, blue: 1.00)
            let indigo = Color(red: 0.29, green: 0.23, blue: 0.62)

            ZStack {
                // Primary violet bloom anchored at the bottom — the heart of the Speak look
                RadialGradient(
                    colors: [
                        violet.opacity(0.92 * bloom),
                        indigo.opacity(0.52 * bloom),
                        Color.clear
                    ],
                    center: UnitPoint(x: centerX, y: 0.96),
                    startRadius: 2,
                    endRadius: mainRadius
                )
                .blendMode(.screen)
                .blur(radius: 14)

                // Diffuse indigo wash drifting at a different rate — gives the bloom layered depth
                RadialGradient(
                    colors: [
                        indigo.opacity(0.46 * secondaryRaw),
                        indigo.opacity(0.18),
                        Color.clear
                    ],
                    center: UnitPoint(x: secondaryX, y: 0.74),
                    startRadius: 1,
                    endRadius: height * 1.3
                )
                .blendMode(.screen)
                .blur(radius: 22)

                // Lavender highlight surfaces at peak — the glowing top of the bloom
                RadialGradient(
                    colors: [
                        lavender.opacity(0.42 * pow(bloom, 1.4)),
                        violet.opacity(0.14 * bloom),
                        Color.clear
                    ],
                    center: UnitPoint(x: centerX, y: 0.62),
                    startRadius: 1,
                    endRadius: bonIntentLerp(38, 70, CGFloat(bloom))
                )
                .blendMode(.screen)
                .blur(radius: 10)

                // Lime peak — surfaces near the brightest bloom moments for brand identity
                RadialGradient(
                    colors: [
                        BONColor.lime100.opacity(0.48 * pow(bloom, 1.8)),
                        BONColor.lime200.opacity(0.16 * pow(bloom, 1.8)),
                        Color.clear
                    ],
                    center: UnitPoint(x: centerX, y: 0.85),
                    startRadius: 1,
                    endRadius: bonIntentLerp(22, 42, CGFloat(bloom))
                )
                .blendMode(.screen)
                .blur(radius: 7)
            }
            .frame(width: width, height: height)
            .opacity(activeProgress)
            .clipShape(Capsule(style: .continuous))
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Dark CTA: lime border bead orbiting the capsule edge
//
// Non-private so other dark-glass surfaces (e.g. `FirstTimerChatComposer` on
// the AI Chat screen) can opt into the same orbit-bead treatment without
// duplicating the recipe.

struct BONDarkIntentBorderLight: View {
    let phase: TimeInterval
    let activeProgress: CGFloat
    let isPressed: Bool
    let isActive: Bool

    var body: some View {
        let capsule = Capsule(style: .continuous)
        let cycle: TimeInterval = 4.6
        let raw = isActive ? (phase.truncatingRemainder(dividingBy: cycle) / cycle) : 0.28
        let angle = Angle.degrees(raw * 360 - 90) // start at top
        let pressBoost: CGFloat = isPressed ? 1.18 : 1.0

        return ZStack {
            // Outer wide bloom — softest glow that gives the bead its halo on the dark base
            capsule
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: BONColor.lime100.opacity(0.0), location: 0.38),
                            .init(color: BONColor.lime100.opacity(0.48 * pressBoost), location: 0.50),
                            .init(color: BONColor.lime100.opacity(0.0), location: 0.62),
                            .init(color: .clear, location: 1.00)
                        ]),
                        center: .center,
                        angle: angle
                    ),
                    lineWidth: 10
                )
                .blur(radius: 8)
                .blendMode(.screen)

            // Inner bloom halo — tighter, brighter lime glow around the white core
            capsule
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: BONColor.lime100.opacity(0.0), location: 0.43),
                            .init(color: BONColor.lime100.opacity(0.88 * pressBoost), location: 0.50),
                            .init(color: BONColor.lime100.opacity(0.0), location: 0.57),
                            .init(color: .clear, location: 1.00)
                        ]),
                        center: .center,
                        angle: angle
                    ),
                    lineWidth: 5
                )
                .blur(radius: 3)
                .blendMode(.screen)

            // Crisp white bead — the sharp point of light at the centre of the halo
            capsule
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.00),
                            .init(color: Color.white.opacity(0.0), location: 0.47),
                            .init(color: Color.white.opacity(0.98 * pressBoost), location: 0.50),
                            .init(color: Color.white.opacity(0.0), location: 0.53),
                            .init(color: .clear, location: 1.00)
                        ]),
                        center: .center,
                        angle: angle
                    ),
                    lineWidth: 1.4
                )
                .blur(radius: 0.4)
                .blendMode(.screen)

            // Subtle resting rim so the capsule has a finished edge when the bead is far away
            capsule
                .stroke(Color.white.opacity(0.14), lineWidth: 0.7)
        }
        .opacity(activeProgress)
        .allowsHitTesting(false)
    }
}

// MARK: - Lime caustic shimmer (unchanged behaviour)

private struct BONIntentCTACaustic: View {
    let phase: TimeInterval
    let isPressed: Bool
    let isActive: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let cycle: TimeInterval = 5.6
            let raw = CGFloat(phase.truncatingRemainder(dividingBy: cycle) / cycle)
            let x = (-width * 0.42) + (raw * width * 1.84)
            let causticOpacity = isActive ? (isPressed ? 0.72 : 0.50) : 0

            ZStack {
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                BONColor.lime50.opacity(0.64),
                                BONColor.lime100.opacity(0.48),
                                BONColor.lime200.opacity(0.38),
                                BONColor.lime300.opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isPressed ? 3.0 : 2.0
                    )
                    .blur(radius: isPressed ? 1.2 : 1.8)

                LinearGradient(
                    colors: [
                        Color.clear,
                        BONColor.lime50.opacity(0.02),
                        BONColor.lime50.opacity(0.62),
                        BONColor.lime100.opacity(0.30),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: 54, height: height * 1.9)
                .rotationEffect(.degrees(18))
                .offset(x: x, y: -height * 0.42)
                .blendMode(.screen)

                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.52),
                                Color.white.opacity(0.00),
                                BONColor.lime300.opacity(0.24)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.4
                    )
                    .offset(y: isPressed ? 1 : 0)
            }
            .opacity(causticOpacity)
            .clipShape(Capsule(style: .continuous))
            .animation(.easeOut(duration: 0.16), value: isPressed)
        }
    }
}

private func bonIntentLerp(_ start: CGFloat, _ end: CGFloat, _ progress: CGFloat) -> CGFloat {
    start + ((end - start) * min(1, max(0, progress)))
}

#Preview {
    VStack(spacing: BONSpacing.md) {
        BONPrimaryButton(title: "Continue", systemImage: "arrow.right") {}
        BONPrimaryButton(title: "Loading", isLoading: true) {}
        BONPrimaryButton(title: "Disabled", isDisabled: true) {}
        BONIntentCTA(title: "Build your plan") {}
            .frame(height: 48)
        BONIntentCTA(title: "Link card", theme: .dark) {}
            .frame(width: 294, height: 48)
    }
    .padding()
    .background(BONColor.canvas)
}
