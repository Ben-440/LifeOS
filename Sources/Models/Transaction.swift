import Foundation

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    let id: UUID
    let title: String
    let amount: Decimal
    let category: TransactionCategory
    let date: Date
    let notes: String?
    var isExpense: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        category: TransactionCategory,
        date: Date = Date(),
        notes: String? = nil,
        isExpense: Bool = true
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        self.isExpense = isExpense
    }
    
    // MARK: - Codable Conformance for Decimal
    enum CodingKeys: String, CodingKey {
        case id, title, amount, category, date, notes, isExpense
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(amount.stringValue, forKey: .amount) // Encode Decimal as String
        try container.encode(category, forKey: .category)
        try container.encode(date, forKey: .date)
        try container.encode(notes, forKey: .notes)
        try container.encode(isExpense, forKey: .isExpense)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let amountString = try container.decode(String.self, forKey: .amount)
        amount = Decimal(string: amountString) ?? 0
        category = try container.decode(TransactionCategory.self, forKey: .category)
        date = try container.decode(Date.self, forKey: .date)
        notes = try container.decode(String?.self, forKey: .notes)
        isExpense = try container.decode(Bool.self, forKey: .isExpense)
    }
}

// MARK: - Transaction Category
enum TransactionCategory: String, Codable, CaseIterable {
    case food = "Food & Dining"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case healthcare = "Healthcare"
    case education = "Education"
    case salary = "Salary"
    case investment = "Investment"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "🍔"
        case .transportation: return "🚗"
        case .shopping: return "🛍️"
        case .entertainment: return "🎬"
        case .utilities: return "💡"
        case .healthcare: return "⚕️"
        case .education: return "📚"
        case .salary: return "💰"
        case .investment: return "📈"
        case .other: return "📌"
        }
    }
}

// MARK: - Monthly Budget
struct MonthlyBudget: Identifiable, Codable {
    let id: UUID
    let category: TransactionCategory
    let limit: Decimal
    let month: Int // 1-12
    let year: Int
    
    init(
        id: UUID = UUID(),
        category: TransactionCategory,
        limit: Decimal,
        month: Int = Calendar.current.component(.month, from: Date()),
        year: Int = Calendar.current.component(.year, from: Date())
    ) {
        self.id = id
        self.category = category
        self.limit = limit
        self.month = month
        self.year = year
    }
    
    // MARK: - Codable Conformance for Decimal
    enum CodingKeys: String, CodingKey {
        case id, category, limit, month, year
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(limit.stringValue, forKey: .limit) // Encode Decimal as String
        try container.encode(month, forKey: .month)
        try container.encode(year, forKey: .year)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decode(TransactionCategory.self, forKey: .category)
        let limitString = try container.decode(String.self, forKey: .limit)
        limit = Decimal(string: limitString) ?? 0
        month = try container.decode(Int.self, forKey: .month)
        year = try container.decode(Int.self, forKey: .year)
    }
}

// MARK: - Summary Statistics
struct SummaryStatistics: Codable {
    let totalIncome: Decimal
    let totalExpenses: Decimal
    let netSavings: Decimal
    let categoryBreakdown: [TransactionCategory: Decimal]
    let period: DateInterval
}
