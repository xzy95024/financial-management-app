import Foundation
import FirebaseFirestore

// MARK: - Transaction Model
struct Transaction: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var amount: Double
    var type: TransactionType
    var categoryId: String
    var categoryName: String?
    var merchantId: String?
    var merchantName: String?
    var description: String?
    var date: Date
    var location: Location?
    var imageURL: String?
    var createdAt: Date
    var updatedAt: Date
    
    /// Income / Expense type for a transaction
    enum TransactionType: String, CaseIterable, Codable {
        case income = "income"
        case expense = "expense"
        
        /// Display name used in the UI
        var displayName: String {
            switch self {
            case .income:
                return "Income"
            case .expense:
                return "Expense"
            }
        }
        
        /// Hex color string used in charts / tags
        var color: String {
            switch self {
            case .income:
                return "#4CAF50" // Green
            case .expense:
                return "#F44336" // Red
            }
        }
    }
    
    init(
        userId: String,
        amount: Double,
        type: TransactionType,
        categoryId: String,
        categoryName: String,
        merchantId: String? = nil,
        merchantName: String? = nil,
        description: String? = nil,
        date: Date = Date(),
        location: Location? = nil,
        imageURL: String? = nil
    ) {
        self.userId = userId
        self.amount = amount
        self.type = type
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.merchantId = merchantId
        self.merchantName = merchantName
        self.description = description
        self.date = date
        self.location = location
        self.imageURL = imageURL
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Category Model
struct Category: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var icon: String
    var color: String
    var isDefault: Bool
    var userId: String?
    var createdAt: Date
    
    init(
        name: String,
        icon: String,
        color: String,
        isDefault: Bool = false,
        userId: String? = nil
    ) {
        self.name = name
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
        self.userId = userId
        self.createdAt = Date()
    }
    
    /// Default categories (shared across income & expense)
    static let defaultCategories: [Category] = [
        Category(name: "Dining",        icon: "🍽️", color: "#FF9800", isDefault: true),
        Category(name: "Transport",     icon: "🚗", color: "#2196F3", isDefault: true),
        Category(name: "Shopping",      icon: "🛍️", color: "#E91E63", isDefault: true),
        Category(name: "Entertainment", icon: "🎮", color: "#9C27B0", isDefault: true),
        Category(name: "Healthcare",    icon: "🏥", color: "#F44336", isDefault: true),
        Category(name: "Education",     icon: "📚", color: "#3F51B5", isDefault: true),
        Category(name: "Housing",       icon: "🏠", color: "#795548", isDefault: true),
        Category(name: "Salary",        icon: "💰", color: "#4CAF50", isDefault: true),
        Category(name: "Bonus",         icon: "🎁", color: "#8BC34A", isDefault: true),
        Category(name: "Investment",    icon: "📈", color: "#CDDC39", isDefault: true),
        Category(name: "Side Job",      icon: "💼", color: "#FFC107", isDefault: true),
        Category(name: "Transfer",      icon: "💸", color: "#00BCD4", isDefault: true),
        Category(name: "Gifts",         icon: "🎀", color: "#FF5722", isDefault: true),
        Category(name: "Other",         icon: "📦", color: "#607D8B", isDefault: true)
    ]
}

// MARK: - Merchant Model
struct Merchant: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    /// Normalized merchant name (e.g. lowercased, no spaces)
    var merchantKey: String
    /// Display name shown in UI
    var merchantDisplayName: String
    var note: MerchantNote
    var stats: MerchantStats
    /// Recent transactions associated with this merchant
    var recentTransactions: [RecentTransaction]
    var createdAt: Date
    var updatedAt: Date
    
    // Backwards-compatible computed properties
    var name: String { merchantDisplayName }
    var category: String { note.category ?? "Other" }
    var location: Location? { note.location }
    var isFrequent: Bool { stats.visitCount >= 5 }
    var transactionCount: Int { stats.visitCount }
    
    init(
        userId: String,
        merchantKey: String,
        merchantDisplayName: String,
        note: MerchantNote = MerchantNote(),
        stats: MerchantStats = MerchantStats()
    ) {
        self.userId = userId
        self.merchantKey = merchantKey
        self.merchantDisplayName = merchantDisplayName
        self.note = note
        self.stats = stats
        self.recentTransactions = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    /// Convenience initializer
    init(
        userId: String,
        merchantKey: String,
        merchantDisplayName: String
    ) {
        self.init(
            userId: userId,
            merchantKey: merchantKey,
            merchantDisplayName: merchantDisplayName,
            note: MerchantNote(),
            stats: MerchantStats()
        )
    }
}

// MARK: - Recent Transaction Model
struct RecentTransaction: Codable, Identifiable {
    var id: String
    var amount: Double
    var date: Date
    var categoryName: String
    var categoryId: String
    var type: Transaction.TransactionType
    
    init(
        id: String,
        amount: Double,
        date: Date,
        categoryName: String,
        categoryId: String,
        type: Transaction.TransactionType
    ) {
        self.id = id
        self.amount = amount
        self.date = date
        self.categoryName = categoryName
        self.categoryId = categoryId
        self.type = type
    }
}

// MARK: - Merchant Note Model
struct MerchantNote: Codable {
    /// 1–5 rating
    var rating: Int?
    /// Recommendation status
    var verdict: MerchantVerdict?
    /// Short hints / tips for future visits
    var tips: [String]
    /// Pros about this merchant
    var pros: [String]
    /// Cons about this merchant
    var cons: [String]
    /// Free-form note text
    var raw: String?
    /// Merchant category label
    var category: String?
    /// Optional location info
    var location: Location?
    
    enum MerchantVerdict: String, CaseIterable, Codable {
        case recommended = "recommended"
        case avoid = "avoid"
        case neutral = "neutral"
        
        /// Display name for UI
        var displayName: String {
            switch self {
            case .recommended:
                return "Recommended"
            case .avoid:
                return "Avoid"
            case .neutral:
                return "Neutral"
            }
        }
        
        /// Hex color string for badges / tags
        var color: String {
            switch self {
            case .recommended:
                return "#4CAF50" // Green
            case .avoid:
                return "#F44336" // Red
            case .neutral:
                return "#FF9800" // Orange
            }
        }
    }
    
    init(
        rating: Int? = nil,
        verdict: MerchantVerdict? = nil,
        tips: [String] = [],
        pros: [String] = [],
        cons: [String] = [],
        raw: String? = nil,
        category: String? = nil,
        location: Location? = nil
    ) {
        self.rating = rating
        self.verdict = verdict
        self.tips = tips
        self.pros = pros
        self.cons = cons
        self.raw = raw
        self.category = category
        self.location = location
    }
}

// MARK: - Merchant Stats Model
struct MerchantStats: Codable {
    /// Total spending at this merchant
    var totalSpending: Double
    /// Number of visits / transactions
    var visitCount: Int
    /// Date of the latest transaction
    var lastVisitDate: Date?
    
    init(
        totalSpending: Double = 0.0,
        visitCount: Int = 0,
        lastVisitDate: Date? = nil
    ) {
        self.totalSpending = totalSpending
        self.visitCount = visitCount
        self.lastVisitDate = lastVisitDate
    }
}

// MARK: - Location Model
struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var address: String?
    var city: String?
    var country: String?
    
    init(
        latitude: Double,
        longitude: Double,
        address: String? = nil,
        city: String? = nil,
        country: String? = nil
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.country = country
    }
}

// MARK: - Budget Model
struct Budget: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var categoryId: String
    var categoryName: String
    var amount: Double
    var period: BudgetPeriod
    var startDate: Date
    var endDate: Date
    var spent: Double
    var createdAt: Date
    var updatedAt: Date
    
    enum BudgetPeriod: String, CaseIterable, Codable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
        
        /// User-facing label for budget period
        var displayName: String {
            switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .monthly:
                return "Monthly"
            case .yearly:
                return "Yearly"
            }
        }
    }
    
    /// Remaining amount before hitting the limit
    var remainingAmount: Double {
        return max(0, amount - spent)
    }
    
    /// 0.0–1.0 progress value
    var progressPercentage: Double {
        return amount > 0 ? min(1.0, spent / amount) : 0
    }
    
    /// Whether the budget is already exceeded
    var isOverBudget: Bool {
        return spent > amount
    }
    
    init(
        userId: String,
        categoryId: String,
        categoryName: String,
        amount: Double,
        period: BudgetPeriod,
        startDate: Date,
        endDate: Date,
        spent: Double = 0
    ) {
        self.userId = userId
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.amount = amount
        self.period = period
        self.startDate = startDate
        self.endDate = endDate
        self.spent = spent
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Statistics Period
enum StatisticsPeriod: String, CaseIterable, Codable {
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
    
    /// Display name for statistics filter chips
    var displayName: String {
        switch self {
        case .day:
            return "Today"
        case .week:
            return "This Week"
        case .month:
            return "This Month"
        case .year:
            return "This Year"
        }
    }
}

// MARK: - Statistics Model
public struct TransactionStatistics: Codable {
    var totalIncome: Double
    var totalExpense: Double
    var netAmount: Double
    var transactionCount: Int
    var categoryBreakdown: [CategoryStatistic]
    var monthlyTrend: [MonthlyStatistic]
    var period: StatisticsPeriod
    
    /// Alias for netAmount, used in UI as "Balance"
    var balance: Double {
        return totalIncome - totalExpense
    }
}

struct CategoryStatistic: Codable, Identifiable {
    var id = UUID()
    var categoryId: String
    var categoryName: String
    var categoryIcon: String
    var categoryColor: String
    var amount: Double
    var percentage: Double
    var transactionCount: Int
    var type: Transaction.TransactionType
}

struct MonthlyStatistic: Codable, Identifiable {
    var id = UUID()
    var month: String
    var income: Double
    var expense: Double
    var net: Double
    var date: Date
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let transactionAdded   = Notification.Name("transactionAdded")
    static let transactionUpdated = Notification.Name("transactionUpdated")
    static let transactionDeleted = Notification.Name("transactionDeleted")
    static let categoriesUpdated  = Notification.Name("categoriesUpdated")
    static let merchantsUpdated   = Notification.Name("merchantsUpdated")
    static let budgetUpdated      = Notification.Name("budgetUpdated")
}
