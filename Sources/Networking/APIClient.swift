import Foundation

// MARK: - API Client
actor APIClient {
    static let shared = APIClient()
    
    private let baseURL: URL
    private let session: URLSession
    
    private init() {
        // Default to localhost for development, can be configured
        self.baseURL = URL(string: ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:3000")!
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Transactions
    func fetchTransactions() async throws -> [Transaction] {
        let url = baseURL.appendingPathComponent("api/transactions")
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([Transaction].self, from: data)
    }
    
    func postTransactions(_ transactions: [Transaction]) async {
        guard !transactions.isEmpty else { return }
        
        let url = baseURL.appendingPathComponent("api/transactions/sync")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(transactions)
            let _ = try await session.data(for: request)
        } catch {
            print("Failed to post transactions: \(error)")
        }
    }
    
    // MARK: - Budgets
    func fetchBudgets() async throws -> [MonthlyBudget] {
        let url = baseURL.appendingPathComponent("api/budgets")
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([MonthlyBudget].self, from: data)
    }
    
    func postBudgets(_ budgets: [MonthlyBudget]) async {
        guard !budgets.isEmpty else { return }
        
        let url = baseURL.appendingPathComponent("api/budgets/sync")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(budgets)
            let _ = try await session.data(for: request)
        } catch {
            print("Failed to post budgets: \(error)")
        }
    }
}

// MARK: - Local Data Store
actor LocalDataStore {
    static let shared = LocalDataStore()
    
    private let fileManager = FileManager.default
    private let transactionsFile: URL
    private let budgetsFile: URL
    
    private init() {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appFolder = appSupport.appendingPathComponent("FinanceTracker")
        
        do {
            try fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        } catch {
            print("Failed to create app folder: \(error)")
        }
        
        self.transactionsFile = appFolder.appendingPathComponent("transactions.json")
        self.budgetsFile = appFolder.appendingPathComponent("budgets.json")
    }
    
    // MARK: - Transactions
    func loadTransactions() -> [Transaction] {
        guard fileManager.fileExists(atPath: transactionsFile.path) else { return [] }
        
        do {
            let data = try Data(contentsOf: transactionsFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Transaction].self, from: data)
        } catch {
            print("Failed to load transactions: \(error)")
            return []
        }
    }
    
    func saveTransaction(_ transaction: Transaction) {
        var transactions = loadTransactions()
        
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            transactions[index] = transaction
        } else {
            transactions.append(transaction)
        }
        
        saveTransactions(transactions)
    }
    
    func deleteTransaction(_ id: UUID) {
        var transactions = loadTransactions()
        transactions.removeAll { $0.id == id }
        saveTransactions(transactions)
    }
    
    private func saveTransactions(_ transactions: [Transaction]) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(transactions)
            try data.write(to: transactionsFile)
        } catch {
            print("Failed to save transactions: \(error)")
        }
    }
    
    // MARK: - Budgets
    func loadBudgets() -> [MonthlyBudget] {
        guard fileManager.fileExists(atPath: budgetsFile.path) else { return [] }
        
        do {
            let data = try Data(contentsOf: budgetsFile)
            return try JSONDecoder().decode([MonthlyBudget].self, from: data)
        } catch {
            print("Failed to load budgets: \(error)")
            return []
        }
    }
    
    func saveBudget(_ budget: MonthlyBudget) {
        var budgets = loadBudgets()
        
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
        } else {
            budgets.append(budget)
        }
        
        saveBudgets(budgets)
    }
    
    private func saveBudgets(_ budgets: [MonthlyBudget]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(budgets)
            try data.write(to: budgetsFile)
        } catch {
            print("Failed to save budgets: \(error)")
        }
    }
}
