import Foundation

final class AppRouter: ObservableObject {
    @Published var path: [AppRoute]
    @Published var aiEntrySource: AIChatEntrySource = .cta
    @Published var usesAIChatLaunchArguments = false

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-BONInitialRoute"),
           arguments.indices.contains(index + 1) {
            switch arguments[index + 1].lowercased() {
            case "ai-chat":
                path = [.aiChat]
                usesAIChatLaunchArguments = true
            case "credit":
                path = [.credit]
            default:
                path = []
            }
        } else if let index = arguments.firstIndex(of: "-BONHomeFirstTimerState"),
                  arguments.indices.contains(index + 1) {
            // The legacy QA / first-launch flag `-BONHomeFirstTimerState ai|
            // ai-landing|report` used to render the AI Chat inline in the home
            // view via a private `surface = .aiLanding` state. The chat is now
            // a real NavigationStack destination, so we translate those values
            // into a push of `.aiChat` at startup.
            switch arguments[index + 1].lowercased() {
            case "ai", "ai-landing", "report":
                path = [.aiChat]
            default:
                path = []
            }
        } else {
            path = []
        }
    }

    func openAIChat(source: AIChatEntrySource) {
        aiEntrySource = source
        usesAIChatLaunchArguments = false
        DispatchQueue.main.async { [weak self] in
            self?.path.append(.aiChat)
        }
    }

    func openCredit() {
        usesAIChatLaunchArguments = false
        DispatchQueue.main.async { [weak self] in
            self?.path.append(.credit)
        }
    }

    func openSpend() {
        usesAIChatLaunchArguments = false
        DispatchQueue.main.async { [weak self] in
            self?.path.append(.spend)
        }
    }

    func reset() {
        usesAIChatLaunchArguments = false
        path.removeAll()
    }
}
