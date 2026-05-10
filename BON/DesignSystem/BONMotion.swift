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

    static let fastTiming = BONMotionTiming(duration: 0.16)
    static let standardTiming = BONMotionTiming(duration: 0.24)
    static let emphasisTiming = BONMotionTiming(duration: 0.42)

    // Compatibility aliases for the current scaffold.
    static let settle = reveal
    static let fade = Animation.easeInOut(duration: 0.2)
}
