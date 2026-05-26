import Foundation
import SwiftUI

// MARK: - Sub-tab inside the Spend screen

enum SpendSubTab: String, CaseIterable, Hashable, Identifiable {
    case transactions
    case recurring
    case budgeting

    var id: String { rawValue }

    var title: String {
        switch self {
        case .transactions: return "Transactions"
        case .recurring: return "Recurring"
        case .budgeting: return "Budgeting"
        }
    }
}

// MARK: - Budgeting flow stage

/// Drives the in-flow navigation for the first-time budgeting funnel.
/// Self-contained so it does not need to be added to the shared `AppRoute` enum.
enum SpendBudgetingStage: Hashable {
    case intro
    case manualEntry
    case planLocked
    case dashboard
}

// MARK: - "Build your plan" options (sheet)

enum BuildPlanOption: String, CaseIterable, Hashable, Identifiable {
    case manual
    case automatic

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: return "Fill details manually"
        case .automatic: return "Automatically filled"
        }
    }

    var subtitle: String {
        switch self {
        case .manual: return "Takes ~2 mins"
        case .automatic: return "Takes ~30 secs  |  Accounts linking required"
        }
    }
}

// MARK: - Budget category model

struct BudgetCategoryGroup: Identifiable, Hashable {
    let id: String
    let title: String
    var items: [BudgetCategoryItem]
}

struct BudgetCategoryItem: Identifiable, Hashable {
    let id: String
    let title: String
    let symbol: String
    var monthlyAmount: Decimal
    var spent: Decimal
}

extension BudgetCategoryGroup {
    /// Default scaffolding pulled from the Figma "Build your plan – manually" screen.
    static let starterTemplate: [BudgetCategoryGroup] = [
        BudgetCategoryGroup(
            id: "income",
            title: "Monthly Income",
            items: [
                BudgetCategoryItem(id: "income.salary", title: "Income 1", symbol: "banknote.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "income.side", title: "Incoming total", symbol: "arrow.down.circle.fill", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "housing",
            title: "Housing",
            items: [
                BudgetCategoryItem(id: "housing.rent", title: "Mortgage/Rent", symbol: "house.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "housing.water", title: "Water", symbol: "drop.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "housing.natural-gas", title: "Natural gas", symbol: "flame.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "housing.electricity", title: "Electricity", symbol: "bolt.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "housing.cable", title: "Cable", symbol: "tv.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "housing.trash", title: "Trash", symbol: "trash.fill", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "transport",
            title: "Transportation",
            items: [
                BudgetCategoryItem(id: "transport.gas", title: "Gas & transport", symbol: "fuelpump.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "transport.maintenance", title: "Maintenance", symbol: "wrench.and.screwdriver.fill", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "food",
            title: "Food",
            items: [
                BudgetCategoryItem(id: "food.groceries", title: "Groceries", symbol: "cart.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "food.restaurants", title: "Restaurants", symbol: "fork.knife", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "personal",
            title: "Personal",
            items: [
                BudgetCategoryItem(id: "personal.clothing", title: "Clothing", symbol: "tshirt.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "personal.subscriptions", title: "Subscriptions", symbol: "rectangle.stack.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "personal.phone", title: "Phone", symbol: "iphone", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "personal.fun", title: "Fun money", symbol: "gift.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "personal.hair", title: "Hair & cosmetics", symbol: "sparkles", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "lifestyle",
            title: "Lifestyle",
            items: [
                BudgetCategoryItem(id: "lifestyle.pet", title: "Pet care", symbol: "pawprint.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "lifestyle.child", title: "Child care", symbol: "figure.2.and.child.holdinghands", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "health",
            title: "Health",
            items: [
                BudgetCategoryItem(id: "health.gym", title: "Gym", symbol: "dumbbell.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "health.medicine", title: "Medicine/Vitamins", symbol: "pills.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "health.doctor", title: "Doctor visits", symbol: "stethoscope", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "insurance",
            title: "Insurance",
            items: [
                BudgetCategoryItem(id: "insurance.health", title: "Health insurance", symbol: "heart.text.square.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "insurance.life", title: "Life insurance", symbol: "shield.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "insurance.auto", title: "Auto insurance", symbol: "car.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "insurance.identity", title: "Identity theft", symbol: "person.badge.shield.checkmark.fill", monthlyAmount: 0, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "debt",
            title: "Debt",
            items: [
                BudgetCategoryItem(id: "debt.cc", title: "Credit card minimums", symbol: "creditcard.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "debt.auto", title: "Auto debt", symbol: "car.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "debt.student", title: "Student debt", symbol: "graduationcap.fill", monthlyAmount: 0, spent: 0),
                BudgetCategoryItem(id: "debt.personal", title: "Personal debt", symbol: "person.fill", monthlyAmount: 0, spent: 0)
            ]
        )
    ]

    /// Locked-plan summary shown after the user builds a plan. Matches Figma frame
    /// 142:12642 ("Plan locked") spending breakdown and totals on the dashboard.
    static let lockedSummary: [BudgetCategoryGroup] = [
        BudgetCategoryGroup(
            id: "summary",
            title: "Summary",
            items: [
                BudgetCategoryItem(id: "summary.incoming", title: "Incoming", symbol: "arrow.down.circle.fill", monthlyAmount: 1400, spent: 0),
                BudgetCategoryItem(id: "summary.housing", title: "Housing", symbol: "house.fill", monthlyAmount: 245, spent: 0),
                BudgetCategoryItem(id: "summary.transport", title: "Transportation", symbol: "car.fill", monthlyAmount: 97, spent: 0),
                BudgetCategoryItem(id: "summary.personal", title: "Personal", symbol: "person.fill", monthlyAmount: 545, spent: 0)
            ]
        )
    ]

    /// Active dashboard data (Figma frame 142:12778).
    static let activeDashboard: [BudgetCategoryGroup] = [
        BudgetCategoryGroup(
            id: "housing",
            title: "Housing",
            items: [
                BudgetCategoryItem(id: "h.rent", title: "Mortgage/Rent", symbol: "house.fill", monthlyAmount: 2400, spent: 1480),
                BudgetCategoryItem(id: "h.elec", title: "Electricity", symbol: "bolt.fill", monthlyAmount: 220, spent: 87),
                BudgetCategoryItem(id: "h.gas", title: "Natural gas", symbol: "flame.fill", monthlyAmount: 180, spent: 122),
                BudgetCategoryItem(id: "h.water", title: "Water", symbol: "drop.fill", monthlyAmount: 80, spent: 32),
                BudgetCategoryItem(id: "h.cable", title: "Cable", symbol: "tv.fill", monthlyAmount: 120, spent: 89),
                BudgetCategoryItem(id: "h.trash", title: "Trash", symbol: "trash.fill", monthlyAmount: 60, spent: 22)
            ]
        ),
        BudgetCategoryGroup(
            id: "transport",
            title: "Transportation",
            items: [
                BudgetCategoryItem(id: "t.gas", title: "Gas", symbol: "fuelpump.fill", monthlyAmount: 320, spent: 287),
                BudgetCategoryItem(id: "t.maint", title: "Maintenance", symbol: "wrench.and.screwdriver.fill", monthlyAmount: 150, spent: 110)
            ]
        ),
        BudgetCategoryGroup(
            id: "food",
            title: "Food",
            items: [
                BudgetCategoryItem(id: "f.groc", title: "Groceries", symbol: "cart.fill", monthlyAmount: 540, spent: 412),
                BudgetCategoryItem(id: "f.rest", title: "Restaurants", symbol: "fork.knife", monthlyAmount: 240, spent: 264)
            ]
        ),
        BudgetCategoryGroup(
            id: "personal",
            title: "Personal",
            items: [
                BudgetCategoryItem(id: "p.cloth", title: "Clothing", symbol: "tshirt.fill", monthlyAmount: 180, spent: 0),
                BudgetCategoryItem(id: "p.subs", title: "Subscriptions", symbol: "rectangle.stack.fill", monthlyAmount: 90, spent: 78),
                BudgetCategoryItem(id: "p.phone", title: "Phone", symbol: "iphone", monthlyAmount: 100, spent: 100),
                BudgetCategoryItem(id: "p.fun", title: "Fun money", symbol: "gift.fill", monthlyAmount: 150, spent: 0),
                BudgetCategoryItem(id: "p.hair", title: "Hair & cosmetics", symbol: "sparkles", monthlyAmount: 80, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "lifestyle",
            title: "Lifestyle",
            items: [
                BudgetCategoryItem(id: "l.pet", title: "Pet care", symbol: "pawprint.fill", monthlyAmount: 80, spent: 0),
                BudgetCategoryItem(id: "l.child", title: "Child care", symbol: "figure.2.and.child.holdinghands", monthlyAmount: 300, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "health",
            title: "Health",
            items: [
                BudgetCategoryItem(id: "he.gym", title: "Gym", symbol: "dumbbell.fill", monthlyAmount: 60, spent: 60),
                BudgetCategoryItem(id: "he.meds", title: "Medicine/Vitamins", symbol: "pills.fill", monthlyAmount: 40, spent: 0),
                BudgetCategoryItem(id: "he.doc", title: "Doctor visits", symbol: "stethoscope", monthlyAmount: 50, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "insurance",
            title: "Insurance",
            items: [
                BudgetCategoryItem(id: "i.health", title: "Health insurance", symbol: "heart.text.square.fill", monthlyAmount: 320, spent: 320),
                BudgetCategoryItem(id: "i.life", title: "Life insurance", symbol: "shield.fill", monthlyAmount: 40, spent: 0),
                BudgetCategoryItem(id: "i.auto", title: "Auto insurance", symbol: "car.fill", monthlyAmount: 140, spent: 0),
                BudgetCategoryItem(id: "i.id", title: "Identity theft", symbol: "person.badge.shield.checkmark.fill", monthlyAmount: 30, spent: 0),
                BudgetCategoryItem(id: "i.home", title: "Home owner / Renter", symbol: "house.lodge.fill", monthlyAmount: 60, spent: 0)
            ]
        ),
        BudgetCategoryGroup(
            id: "debt",
            title: "Debt",
            items: [
                BudgetCategoryItem(id: "d.cc", title: "Credit card minimums", symbol: "creditcard.fill", monthlyAmount: 240, spent: 0),
                BudgetCategoryItem(id: "d.auto", title: "Auto debt", symbol: "car.fill", monthlyAmount: 320, spent: 0),
                BudgetCategoryItem(id: "d.student", title: "Student debt", symbol: "graduationcap.fill", monthlyAmount: 290, spent: 0),
                BudgetCategoryItem(id: "d.personal", title: "Personal debt", symbol: "person.fill", monthlyAmount: 180, spent: 0)
            ]
        )
    ]
}

// MARK: - Computed helpers

extension BudgetCategoryItem {
    /// 0…1 progress of `spent` against `monthlyAmount`, clamped.
    var progress: Double {
        let budget = (monthlyAmount as NSDecimalNumber).doubleValue
        let used = (spent as NSDecimalNumber).doubleValue
        guard budget > 0 else { return used > 0 ? 1 : 0 }
        return max(0, min(used / budget, 1.4))
    }

    /// Difference between budget and actual; negative means over budget.
    var remaining: Decimal {
        monthlyAmount - spent
    }

    var isOverBudget: Bool {
        spent > monthlyAmount && monthlyAmount > 0
    }
}

extension Array where Element == BudgetCategoryItem {
    var totalBudget: Decimal {
        reduce(Decimal(0)) { $0 + $1.monthlyAmount }
    }

    var totalSpent: Decimal {
        reduce(Decimal(0)) { $0 + $1.spent }
    }
}

// MARK: - Currency formatting

enum BudgetCurrency {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static func string(from amount: Decimal) -> String {
        formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }

    static func compact(from amount: Decimal) -> String {
        let value = (amount as NSDecimalNumber).doubleValue
        if abs(value) >= 1000 {
            let thousands = value / 1000
            return String(format: "$%.1fk", thousands)
        }
        return string(from: amount)
    }
}
