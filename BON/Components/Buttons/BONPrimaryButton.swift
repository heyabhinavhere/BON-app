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
                .foregroundStyle(BONColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.88)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(BONIntentCTAStyle(revealProgress: revealProgress, isDisabled: isDisabled))
        .disabled(isDisabled)
        .accessibilityLabel(title)
    }
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
    var isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        BONIntentCTAStyleBody(
            label: configuration.label,
            isPressed: configuration.isPressed,
            revealProgress: revealProgress,
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
                .padding(.horizontal, 24)
                .background {
                    BONIntentCTASurface(
                        phase: phase,
                        revealProgress: resolvedReveal,
                        readyProgress: readyProgress,
                        isPressed: isPressed,
                        isDisabled: isDisabled,
                        reduceMotion: reduceMotion,
                        reduceTransparency: reduceTransparency
                    )
                }
                .scaleEffect(reduceMotion ? 1 : (isPressed ? 0.985 : bonIntentLerp(0.992, 1.0, readyProgress)))
                .shadow(
                    color: Color.black.opacity(reduceTransparency ? 0.08 : 0.10 * activeDepth),
                    radius: isPressed ? 8 : 14,
                    x: 0,
                    y: isPressed ? 3 : 8
                )
                .shadow(
                    color: reduceTransparency ? .clear : BONColor.lime300.opacity((isPressed ? 0.20 : 0.30) * activeDepth),
                    radius: isPressed ? 12 : 22,
                    x: 0,
                    y: isPressed ? 4 : 10
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
}

private struct BONIntentCTASurface: View {
    let phase: TimeInterval
    let revealProgress: CGFloat
    let readyProgress: CGFloat
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
            let baseFill = isDisabled ? BONColor.lime100.opacity(0.42) : BONColor.lime500
            let depthOpacity = reduceTransparency ? 0 : activeProgress

            ZStack {
                capsule
                    .fill(baseFill)

                if !reduceTransparency {
                    capsule
                        .fill(
                            LinearGradient(
                                colors: [
                                    BONColor.lime50.opacity(0.46),
                                    BONColor.lime200.opacity(0.22),
                                    BONColor.lime500.opacity(0.0)
                                ],
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
                    .opacity(depthOpacity)
                }

                capsule
                    .stroke(Color.black.opacity(isDisabled ? 0.18 : 0.92), lineWidth: isPressed ? 1.15 : 1.0)

                capsule
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(reduceTransparency ? 0.22 : 0.62),
                                Color.white.opacity(0.08),
                                Color.black.opacity(0.18)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .opacity(isDisabled ? 0.18 : 0.82)

                if !reduceTransparency {
                    RadialGradient(
                        colors: [
                            Color.white.opacity(isPressed ? 0.40 : 0.0),
                            BONColor.lime50.opacity(isPressed ? 0.22 : 0.0),
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
    }
    .padding()
    .background(BONColor.canvas)
}
