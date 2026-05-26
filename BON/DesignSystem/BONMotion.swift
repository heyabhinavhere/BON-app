import SwiftUI

struct BONMotionTiming {
    let duration: Double
}

enum BONMotion {
    static let instant = Animation.linear(duration: 0.08)
    static let press = Animation.spring(response: 0.18, dampingFraction: 0.82)
    static let reveal = Animation.spring(response: 0.42, dampingFraction: 0.86)
    static let sheetTransition = Animation.spring(response: 0.48, dampingFraction: 0.88)
    static let matchedMorph = Animation.spring(response: 0.52, dampingFraction: 0.86)
    static let scrollPolish = Animation.easeOut(duration: 0.24)
    static let chatIconMorph = Animation.spring(response: 0.28, dampingFraction: 0.84)
    static let chatSuggestionFlow = Animation.spring(response: 0.36, dampingFraction: 0.90)
    static let thinkingPulse = Animation.easeInOut(duration: 0.72).repeatForever(autoreverses: true)
    static let reducedMotionFallback = Animation.easeOut(duration: 0.12)

    /// Apple-style content settle that runs *after* a `.navigationTransition(.zoom)`
    /// lands. Use this to gently slide intro content into place — never on the root
    /// destination view (that would fight the system morph).
    static let postZoomSettle = Animation.spring(response: 0.46, dampingFraction: 0.92)

    /// Slightly slower companion settle for secondary content (suggestions, body
    /// paragraphs) so the screen resolves with a subtle staircase.
    static let postZoomSettleSlow = Animation.spring(response: 0.58, dampingFraction: 0.94)

    static let fastTiming = BONMotionTiming(duration: 0.16)
    static let standardTiming = BONMotionTiming(duration: 0.24)
    static let emphasisTiming = BONMotionTiming(duration: 0.42)

    static let settle = reveal
    static let fade = Animation.easeInOut(duration: 0.2)
}
