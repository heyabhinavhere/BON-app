import SwiftUI

/// Debug-only preview host for the card-linking screens.
///
/// Reached via the `-BONCardLinking <scenario>` launch argument (handled by
/// the additive guard in `RootView.body`). Lets QA capture pixel evidence of
/// each scenario without depending on the production navigation graph, which
/// is currently being modified by three concurrent agents (credit, home
/// animation, budgeting).
///
/// Once the integrator wires the production navigation, this host stays
/// useful as a fast pixel-regression entry point.
struct CardLinkingPreviewHost: View {
    let scenario: CardLinkingScenario

    var body: some View {
        switch scenario {
        case .linkCreditCard:
            LinkCreditCardView()
        case .linkCreditCardGift:
            LinkCreditCardGiftView()
        case .linkBankAccount:
            LinkBankAccountView()
        case .linkCreditCardPopup:
            LinkCreditCardPopupDemo()
        case .linkCreditCardPopupOpen:
            LinkCreditCardPopupAutoOpenDemo()
        case .menu:
            CardLinkingScenarioMenu()
        }
    }
}

enum CardLinkingScenario: String, CaseIterable {
    case linkCreditCard = "link-credit-card"
    case linkCreditCardGift = "link-credit-card-gift"
    case linkBankAccount = "link-bank-account"
    case linkCreditCardPopup = "link-credit-card-popup"
    case linkCreditCardPopupOpen = "link-credit-card-popup-open"
    case menu

    static func fromLaunchArguments() -> CardLinkingScenario? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-BONCardLinking"),
              arguments.indices.contains(index + 1) else {
            return nil
        }
        return CardLinkingScenario(rawValue: arguments[index + 1])
    }

    var title: String {
        switch self {
        case .linkCreditCard: "Scenario A — Link credit card"
        case .linkCreditCardGift: "Scenario B — Link credit card & get $5"
        case .linkBankAccount: "Scenario C — Link bank account"
        case .linkCreditCardPopup: "Scenario D — Link credit card popup"
        case .linkCreditCardPopupOpen: "Scenario D — Link credit card popup (auto-open)"
        case .menu: "All scenarios"
        }
    }
}

/// Fallback menu shown when `-BONCardLinking menu` is passed — useful in QA
/// for quickly hopping between scenarios on the same simulator run.
private struct CardLinkingScenarioMenu: View {
    @State private var selected: CardLinkingScenario?

    var body: some View {
        NavigationStack {
            List {
                ForEach(CardLinkingScenario.allCases.filter { $0 != .menu }, id: \.rawValue) { scenario in
                    NavigationLink(scenario.title, value: scenario)
                }
            }
            .navigationDestination(for: CardLinkingScenario.self) { scenario in
                CardLinkingPreviewHost(scenario: scenario)
            }
            .navigationTitle("Card Linking QA")
        }
    }
}

#Preview("Menu") {
    CardLinkingPreviewHost(scenario: .menu)
}
