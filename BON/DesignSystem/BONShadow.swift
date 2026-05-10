import SwiftUI

struct BONShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let controlSoft = BONShadow(
        color: Color.black.opacity(0.08),
        radius: 32,
        x: 0,
        y: 8
    )
    static let cta = BONShadow(
        color: Color.black.opacity(0.12),
        radius: 32,
        x: 0,
        y: 8
    )
    static let nav = BONShadow(
        color: Color.black.opacity(0.16),
        radius: 12,
        x: 0,
        y: 12
    )
    static let card = BONShadow(
        color: Color.black.opacity(0.08),
        radius: 18,
        x: 0,
        y: 10
    )
    static let pressed = BONShadow(
        color: Color.black.opacity(0.05),
        radius: 8,
        x: 0,
        y: 4
    )

    // Compatibility alias for the current scaffold.
    static let subtle = card
}

struct BONInsetShadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    static let limeGlow = BONInsetShadow(
        color: BONColor.limeGlow,
        radius: 12,
        x: 0,
        y: 0
    )
    static let whiteCTAHighlight = BONInsetShadow(
        color: Color.white.opacity(0.40),
        radius: 8,
        x: 0,
        y: 0
    )
    static let navHighlight = BONInsetShadow(
        color: Color.white.opacity(0.36),
        radius: 8,
        x: 0,
        y: 3
    )
}

extension View {
    func bonShadow(_ shadow: BONShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

