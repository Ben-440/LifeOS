import SwiftUI

// MARK: - Main iOS App
@main
struct FinanceTrackerApp: App {
    @StateObject private var financeManager = FinanceManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(financeManager)
        }
    }
}

// MARK: - App Content View
struct ContentView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var selectedTab: Tab = .dashboard
    
    enum Tab {
        case dashboard
        case transactions
        case budgets
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                .tag(Tab.dashboard)
            
            TransactionsListView()
                .tabItem {
                    Label("Transactions", systemImage: "list.bullet")
                }
                .tag(Tab.transactions)
            
            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "target")
                }
                .tag(Tab.budgets)
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var financeManager: FinanceManager
    
    var currentMonth: DateInterval {
        let calendar = Calendar.current
        let today = Date()
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let range = calendar.range(of: .day, in: .month, for: today)!
        let end = calendar.date(byAdding: .day, value: range.count - 1, to: start)!
        return DateInterval(start: start, end: end)
    }
    
    var summary: SummaryStatistics {
        financeManager.getSummaryForPeriod(currentMonth)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall Summary Cards
                    VStack(spacing: 12) {
                        summaryCard(
                            title: "Net Savings",
                            amount: summary.netSavings,
                            color: summary.netSavings >= 0 ? .green : .red
                        )
                        
                        HStack(spacing: 12) {
                            summaryCard(
                                title: "Income",
                                amount: summary.totalIncome,
                                color: .green
                            )
                            
                            summaryCard(
                                title: "Expenses",
                                amount: summary.totalExpenses,
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Category Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Spending by Category")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if summary.categoryBreakdown.isEmpty {
                            Text("No expenses this month")
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(summary.categoryBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                                    HStack {
                                        Text(category.icon)
                                            .font(.title3)
                                        Text(category.rawValue)
                                            .font(.subheadline)
                                        Spacer()
                                        Text("$\(amount, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func summaryCard(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("$\(amount, specifier: "%.2f")")
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Transactions List View
struct TransactionsListView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddTransaction = false
    
    var body: some View {
        NavigationStack {
            Group {
                if financeManager.transactions.isEmpty {
                    emptyState
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView()
                    .environmentObject(financeManager)
            }
        }
    }
    
    private var transactionsList: some View {
        List {
            ForEach(
                Dictionary(grouping: financeManager.transactions, by: { Calendar.current.startOfDay(for: $0.date) })
                    .sorted(by: { $0.key > $1.key }),
                id: \.key
            ) { date, transactions in
                Section(header: Text(dateFormatter.string(from: date))) {
                    ForEach(transactions.sorted(by: { $0.date > $1.date })) { transaction in
                        TransactionRow(transaction: transaction)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    Task {
                                        await financeManager.deleteTransaction(transaction.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Transactions")
                .font(.headline)
            
            Text("Start tracking your finances by adding your first transaction")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Transaction Row
struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            Text(transaction.category.icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if let notes = transaction.notes {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(transaction.isExpense ? "-" : "+")$\(transaction.amount, specifier: "%.2f")")
                .fontWeight(.semibold)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Transaction View
struct AddTransactionView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .other
    @State private var notes: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    TextField("Title", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Text(category.icon + " " + category.rawValue)
                                .tag(category)
                        }
                    }
                }
                
                Section("More Information") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Notes", text: $notes)
                    
                    Picker("Type", selection: $isExpense) {
                        Text("Expense").tag(true)
                        Text("Income").tag(false)
                    }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !title.isEmpty, !amount.isEmpty else { return }
                        guard let decimalAmount = Decimal(string: amount), decimalAmount > 0 else { return }
                        
                        let transaction = Transaction(
                            title: title,
                            amount: decimalAmount,
                            category: category,
                            date: date,
                            notes: notes.isEmpty ? nil : notes,
                            isExpense: isExpense
                        )
                        
                        Task {
                            await financeManager.addTransaction(transaction)
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
}

// MARK: - Budgets View
struct BudgetsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if financeManager.budgets.isEmpty {
                    emptyState
                } else {
                    budgetsList
                }
            }
            .navigationTitle("Budgets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingAddBudget) {
                AddBudgetView()
                    .environmentObject(financeManager)
            }
        }
    }
    
    private var budgetsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(financeManager.budgets) { budget in
                    if let status = financeManager.getBudgetStatus(for: budget.category) {
                        BudgetCard(status: status)
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Budgets")
                .font(.headline)
            
            Text("Set spending limits for each category to track your budget")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Budget Card
struct BudgetCard: View {
    let status: BudgetStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(status.category.icon)
                    .font(.title2)
                Text(status.category.rawValue)
                    .font(.headline)
                Spacer()
                Text("$\(status.spent, specifier: "%.2f")/$\(status.budget, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(status.isOverBudget ? Color.red : Color.green)
                        .frame(width: geometry.size.width * status.percentageUsed)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\((status.percentageUsed * 100).rounded(toPlaces: 0), specifier: "%.0f")% used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(status.remaining, specifier: "%.2f") remaining")
                    .font(.caption)
                    .foregroundColor(status.isOverBudget ? .red : .green)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Add Budget View
struct AddBudgetView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) var dismiss
    
    @State private var category: TransactionCategory = .food
    @State private var limit: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Budget Details") {
                    Picker("Category", selection: $category) {
                        ForEach(TransactionCategory.allCases, id: \.self) { category in
                            Text(category.icon + " " + category.rawValue)
                                .tag(category)
                        }
                    }
                    
                    HStack {
                        Text("$")
                        TextField("Monthly Limit", text: $limit)
                            .keyboardType(.decimalPad)
                    }
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        guard !limit.isEmpty else { return }
                        guard let decimalLimit = Decimal(string: limit), decimalLimit > 0 else { return }
                        
                        let budget = MonthlyBudget(
                            category: category,
                            limit: decimalLimit
                        )
                        Task {
                            await financeManager.setBudget(budget)
                            dismiss()
                        }
                    }
                    .disabled(limit.isEmpty)
                }
            }
        }
    }
}

// MARK: - Extensions
extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

#Preview {
    ContentView()
        .environmentObject(FinanceManager())
}
