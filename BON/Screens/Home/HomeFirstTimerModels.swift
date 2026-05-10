import Foundation

enum HomeFirstTimerFixture {
    static let navItems = [
        BONBottomNavItem(id: "cards", title: "Cards", imageAsset: "navCards"),
        BONBottomNavItem(id: "spend", title: "Spend", imageAsset: "navSpend"),
        BONBottomNavItem(id: "home", title: "Home", imageAsset: "navHome"),
        BONBottomNavItem(id: "credit", title: "Credit", imageAsset: "navCredit"),
        BONBottomNavItem(id: "money", title: "Money", imageAsset: "navMoney")
    ]

    static let features = [
        HomeFeatureCardContent(title: "Free Smart\nBudgeting", artwork: .budgeting),
        HomeFeatureCardContent(title: "Lift your Credit\nScore", artwork: .creditScore),
        HomeFeatureCardContent(title: "Free Subscription\nmanagement", artwork: .subscriptions)
    ]

    static let primaryFeatures = Array(features.prefix(2))
}

struct HomeFeatureCardContent: Identifiable {
    enum Artwork {
        case budgeting
        case creditScore
        case subscriptions
    }

    let id = UUID()
    let title: String
    let artwork: Artwork
}
