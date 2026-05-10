import SwiftUI

struct BONBottomNavItem: Identifiable {
    let id: String
    let title: String
    let imageAsset: String
}

enum BONBottomNavVariant {
    case expanded
    case compact

    var defaultCollapseProgress: CGFloat {
        switch self {
        case .expanded:
            return 0
        case .compact:
            return 1
        }
    }
}

struct BONBottomNav: View {
    let selectedID: String
    let items: [BONBottomNavItem]
    var width: CGFloat = 342
    var variant: BONBottomNavVariant = .expanded
    var collapseProgress: CGFloat?
    var onSelect: (BONBottomNavItem) -> Void = { _ in }

    var body: some View {
        let progress = resolvedCollapseProgress
        let navWidth = interpolated(expanded: width, compact: 200, progress: progress)
        let navHeight = interpolated(expanded: 64, compact: 44, progress: progress)

        BONBottomNavGlassContainer {
            HStack(spacing: 0) {
                ForEach(items) { item in
                    navButton(for: item, collapseProgress: progress)
                        .frame(
                            width: visualWidth(for: item, collapseProgress: progress),
                            height: buttonHeight(collapseProgress: progress)
                        )

                    if item.id != items.last?.id {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, interpolated(expanded: 36, compact: 18, progress: progress))
            .padding(.vertical, interpolated(expanded: 6, compact: 12, progress: progress))
            .frame(width: navWidth, height: navHeight)
        }
        .frame(width: navWidth, height: navHeight)
    }

    private func navButton(for item: BONBottomNavItem, collapseProgress: CGFloat) -> some View {
        let isSelected = item.id == selectedID
        let foreground = isSelected ? BONColor.textOnDark : BONColor.navInactive
        let labelProgress = 1 - collapseProgress
        let itemWidth = visualWidth(for: item, collapseProgress: collapseProgress)
        let itemHeight = buttonHeight(collapseProgress: collapseProgress)

        return Button {
            Task { @MainActor in
                BONHaptics.selection()
                onSelect(item)
            }
        } label: {
            VStack(spacing: 4 * labelProgress) {
                Image(item.imageAsset)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(foreground)

                if labelProgress > 0.02 {
                    Text(item.title)
                        .font(BONTypography.zalando(size: 10, weight: isSelected ? .light : .ultraLight))
                        .foregroundStyle(foreground)
                        .tracking(0.10)
                        .frame(height: 12 * labelProgress)
                        .scaleEffect(y: max(0.01, labelProgress), anchor: .top)
                        .opacity(labelProgress)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
            .frame(width: itemWidth, height: itemHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(BONScaleButtonStyle())
        .accessibilityLabel(item.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var resolvedCollapseProgress: CGFloat {
        min(1, max(0, collapseProgress ?? variant.defaultCollapseProgress))
    }

    private func visualWidth(for item: BONBottomNavItem, collapseProgress: CGFloat) -> CGFloat {
        interpolated(expanded: expandedVisualWidth(for: item), compact: 20, progress: collapseProgress)
    }

    private func expandedVisualWidth(for item: BONBottomNavItem) -> CGFloat {
        switch item.title {
        case "Cards":
            return 27
        case "Spend", "Money":
            return 31
        default:
            return 28
        }
    }

    private func buttonHeight(collapseProgress: CGFloat) -> CGFloat {
        interpolated(expanded: 36, compact: 20, progress: collapseProgress)
    }

    private func interpolated(expanded: CGFloat, compact: CGFloat, progress: CGFloat) -> CGFloat {
        expanded + ((compact - expanded) * progress)
    }
}

private struct BONBottomNavGlassContainer<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if #available(iOS 26.0, *), !reduceTransparency {
            GlassEffectContainer(spacing: 16) {
                liquidNavContent
            }
        } else {
            fallbackNavContent
        }
    }

    @available(iOS 26.0, *)
    private var liquidNavContent: some View {
        let capsule = Capsule(style: .continuous)

        return content
            .background {
                ZStack {
                    BONBottomNavDarkStain()
                    BONBottomNavSpecularOverlay()
                    BONBottomNavInnerShadow()
                }
            }
            .clipShape(capsule)
            .glassEffect(.regular.tint(Color.black.opacity(0.78)).interactive(), in: capsule)
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 12)
    }

    private var fallbackNavContent: some View {
        ZStack {
            fallbackNavSurface
            content
        }
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.16), radius: 12, x: 0, y: 12)
    }

    @ViewBuilder
    private var fallbackNavSurface: some View {
        let capsule = Capsule(style: .continuous)

        ZStack {
            if reduceTransparency {
                capsule
                    .fill(Color.black.opacity(0.88))
            } else {
                capsule
                    .fill(.ultraThinMaterial)

                capsule
                    .fill(Color.black.opacity(0.64))
            }

            if !reduceTransparency {
                BONBottomNavDarkStain()
            }

            BONBottomNavInnerShadow()
        }
        .clipShape(capsule)
    }
}

private struct BONBottomNavDarkStain: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0.78), location: 0.0),
                        .init(color: Color.black.opacity(0.64), location: 0.50),
                        .init(color: Color.black.opacity(0.52), location: 1.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .allowsHitTesting(false)
    }
}

private struct BONBottomNavSpecularOverlay: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.07),
                        Color.clear,
                        Color.black.opacity(0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.softLight)
            .allowsHitTesting(false)
    }
}

private struct BONBottomNavInnerShadow: View {
    private let shadow = BONInsetShadow.navHighlight

    var body: some View {
        let capsule = Capsule(style: .continuous)

        ZStack {
            capsule
                .strokeBorder(shadow.color, lineWidth: 2.5)
                .blur(radius: 2.5)
                .offset(x: shadow.x, y: 1)
                .mask {
                    capsule
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0.00),
                                    .init(color: .white, location: 0.12),
                                    .init(color: .clear, location: 0.24)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }

            capsule
                .strokeBorder(shadow.color.opacity(0.55), lineWidth: 5)
                .blur(radius: shadow.radius)
                .offset(x: shadow.x, y: shadow.y)
                .mask {
                    capsule
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: .white, location: 0.00),
                                    .init(color: .white.opacity(0.70), location: 0.18),
                                    .init(color: .clear, location: 0.38)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
        }
        .allowsHitTesting(false)
    }
}
