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

    func reset() {
        usesAIChatLaunchArguments = false
        path.removeAll()
    }
}
