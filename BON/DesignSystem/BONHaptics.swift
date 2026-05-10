import Foundation

#if canImport(UIKit)
import UIKit

enum BONHaptics {
    @MainActor
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    @MainActor
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    @MainActor
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    @MainActor
    static func success() {
        notification(.success)
    }

    @MainActor
    static func warning() {
        notification(.warning)
    }

    @MainActor
    static func error() {
        notification(.error)
    }
}
#endif
