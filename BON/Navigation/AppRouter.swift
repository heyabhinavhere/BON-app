import Foundation

final class AppRouter: ObservableObject {
    @Published var path: [AppRoute]
    @Published var aiEntrySource: AIChatEntrySource = .cta
    @Published var usesAIChatLaunchArguments = false

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "-BONInitialRoute"),
           arguments.indices.contains(index + 1),
           arguments[index + 1].lowercased() == "ai-chat" {
            path = [.aiChat]
            usesAIChatLaunchArguments = true
        } else {
            path = []
        }
    }

    func openAIChat(source: AIChatEntrySource) {
        aiEntrySource = source
        usesAIChatLaunchArguments = false
        path.append(.aiChat)
    }

    func reset() {
        usesAIChatLaunchArguments = false
        path.removeAll()
    }
}
