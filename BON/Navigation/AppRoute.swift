import Foundation

enum AIChatEntrySource: String, Hashable {
    case cta
    case modePill

    var transitionID: String {
        rawValue
    }
}

enum AppRoute: Hashable {
    case designAudit
    case aiChat
    case credit
    case spend
}
