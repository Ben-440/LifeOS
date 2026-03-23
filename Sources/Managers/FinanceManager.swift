import Foundation

// MARK: - Finance Manager (Shared across iOS and macOS)
@MainActor
class FinanceManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var budgets: [MonthlyBudget] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let apiClient: APIClient
    private let dataStore: LocalDataStore
    
    init(apiClient: APIClient = APIClient.shared, dataStore: LocalDataStore = LocalDataStore.shared) {
        self.apiClient = apiClient
        self.dataStore = dataStore
        Task {
            await loadData()
        }
    }
    
    // MARK: - Transactions
    func addTransaction(_ transaction: Transaction) async {
        // Save locally first to ensure persistence
        await dataStore.saveTransaction(transaction)
        // Update UI state
        transactions.append(transaction)
        // Sync with backend (non-blocking)
        await syncWithBackend()
    }
    
    func deleteTransaction(_ id: UUID) async {
        transactions.removeAll { $0.id == id }
        await dataStore.deleteTransaction(id)
        await syncWithBackend()
    }
    
    func updateTransaction(_ transaction: Transaction) async {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        }
        await dataStore.saveTransaction(transaction)
        await syncWithBackend()
    }
    
    // MARK: - Budgets
    func setBudget(_ budget: MonthlyBudget) async {
        if let index = budgets.firstIndex(where: { 
            $0.category == budget.category && 
            $0.month == budget.month && 
            $0.year == budget.year 
        }) {
            budgets[index] = budget
        } else {
            budgets.append(budget)
        }
        await syncWithBackend()
        await dataStore.saveBudget(budget)
    }
    
    // MARK: - Analytics
    func getSummaryForPeriod(_ interval: DateInterval) -> SummaryStatistics {
        let periodTransactions = transactions.filter { 
            interval.contains($0.date)
        }
        
        let income = periodTransactions
            .filter { !$0.isExpense }
            .reduce(0) { $0 + $1.amount }
        
        let expenses = periodTransactions
            .filter { $0.isExpense }
            .reduce(0) { $0 + $1.amount }
        
        var categoryBreakdown: [TransactionCategory: Decimal] = [:]
        for transaction in periodTransactions.filter({ $0.isExpense }) {
            categoryBreakdown[transaction.category, default: 0] += transaction.amount
        }
        
        return SummaryStatistics(
            totalIncome: income,
            totalExpenses: expenses,
            netSavings: income - expenses,
            categoryBreakdown: categoryBreakdown,
            period: interval
        )
    }
    
    func getBudgetStatus(for category: TransactionCategory) -> BudgetStatus? {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        guard let budget = budgets.first(where: {
            $0.category == category &&
            $0.month == currentMonth &&
            $0.year == currentYear
        }) else { return nil }
        
        let monthExpenses = transactions.filter { transaction in
            transaction.isExpense &&
            transaction.category == category &&
            Calendar.current.component(.month, from: transaction.date) == currentMonth &&
            Calendar.current.component(.year, from: transaction.date) == currentYear
        }.reduce(0) { $0 + $1.amount }
        
        let isOverBudget = monthExpenses > budget.limit
        
        return BudgetStatus(
            category: category,
            budget: budget.limit,
            spent: monthExpenses,
            remaining: budget.limit - monthExpenses,
            isOverBudget: isOverBudget
        )
    }
    
    // MARK: - Data Management
    private func loadData() async {
        isLoading = true
        defer { isLoading = false }
        
        // Load from local storage first for immediate availability
        self.transactions = await dataStore.loadTransactions()
        self.budgets = await dataStore.loadBudgets()
        
        do {
            // Then sync from backend to get latest data
            await syncFromBackend()
        } catch {
            self.error = error
            // Local data remains available as fallback
        }
    }
    
    private func syncWithBackend() async {
        do {
            await apiClient.postTransactions(transactions)
            await apiClient.postBudgets(budgets)
        } catch {
            self.error = error
            // Data will remain saved locally and synced when connection is restored
        }
    }
    
    private func syncFromBackend() async {
        do {
            self.transactions = try await apiClient.fetchTransactions()
            self.budgets = try await apiClient.fetchBudgets()
        } catch {
            self.error = error
            throw error
        }
    }
}

// MARK: - Budget Status
struct BudgetStatus {
    let category: TransactionCategory
    let budget: Decimal
    let spent: Decimal
    let remaining: Decimal
    let isOverBudget: Bool
    
    var percentageUsed: Double {
        guard budget > 0 else { return 0 }
        let percentage = Double(truncating: (spent / budget) as NSDecimalNumber)
        return min(percentage, 1.0) // Clamp to max 100%
    }
}
