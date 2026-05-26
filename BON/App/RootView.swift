import SwiftUI

struct RootView: View {
    let environment: AppEnvironment
    @EnvironmentObject private var router: AppRouter
    @Namespace private var aiEntryNamespace

    @ViewBuilder
    var body: some View {
        // Card-linking QA hook: `-BONCardLinking <scenario>` short-circuits the
        // production navigation graph so we can capture pixel evidence of the
        // standalone card-linking screens without touching the production
        // navigation files that other agents are currently editing. Removing
        // this branch leaves the production flow untouched.
        if let scenario = CardLinkingScenario.fromLaunchArguments() {
            CardLinkingPreviewHost(scenario: scenario)
        } else {
            productionStack
        }
    }

    private var productionStack: some View {
        NavigationStack(path: $router.path) {
            HomeFirstTimerClickedView(
                aiEntryNamespace: aiEntryNamespace,
                activeAIEntrySource: router.aiEntrySource,
                onOpenAI: { source in
                    router.openAIChat(source: source)
                },
                onOpenCredit: {
                    router.openCredit()
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
                case .credit:
                    CreditView(
                        onHome: {
                            router.reset()
                        },
                        onOpenAI: {
                            router.openAIChat(source: .cta)
                        }
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
