import SwiftUI

struct RootView: View {
    let environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Namespace private var aiEntryNamespace

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeFirstTimerClickedView(
                aiEntryNamespace: aiEntryNamespace,
                activeAIEntrySource: router.aiEntrySource,
                onOpenAI: { source in
                    router.openAIChat(source: source)
                }
            )
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .designAudit:
                    DesignAuditPlaceholderView(environment: environment)
                case .aiChat:
                    AIChatView(
                        entryNamespace: aiEntryNamespace,
                        sourceID: router.aiEntrySource.transitionID,
                        usesLaunchArguments: router.usesAIChatLaunchArguments
                    )
                        .navigationTransition(.zoom(sourceID: router.aiEntrySource.transitionID, in: aiEntryNamespace))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
