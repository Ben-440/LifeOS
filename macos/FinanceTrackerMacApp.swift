import SwiftUI

// MARK: - Main macOS App
@main
struct FinanceTrackerMacApp: App {
    @StateObject private var financeManager = FinanceManager()
    
    var body: some Scene {
        WindowGroup {
            MacContentView()
                .environmentObject(financeManager)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Preferences") {
                    // TODO: Open preferences
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

// MARK: - Main Content View (macOS)
struct MacContentView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var selectedView: MacTab = .dashboard
    
    enum MacTab {
        case dashboard
        case transactions
        case budgets
    }
    
    var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Finance Tracker")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                VStack(spacing: 8) {
                    MacNavButton(
                        label: "Dashboard",
                        icon: "chart.pie.fill",
                        isSelected: selectedView == .dashboard,
                        action: { selectedView = .dashboard }
                    )
                    
                    MacNavButton(
                        label: "Transactions",
                        icon: "list.bullet",
                        isSelected: selectedView == .transactions,
                        action: { selectedView = .transactions }
                    )
                    
                    MacNavButton(
                        label: "Budgets",
                        icon: "target",
                        isSelected: selectedView == .budgets,
                        action: { selectedView = .budgets }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                Divider()
                
                Text("v1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
            }
            .frame(width: 250)
            .background(Color(.controlBackgroundColor))
        } detail: {
            Group {
                switch selectedView {
                case .dashboard:
                    MacDashboardView()
                case .transactions:
                    MacTransactionsView()
                case .budgets:
                    MacBudgetsView()
                }
            }
            .environmentObject(financeManager)
        }
    }
}

// MARK: - Navigation Button (macOS)
struct MacNavButton: View {
    let label: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .frame(width: 20)
                Text(label)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dashboard View (macOS)
struct MacDashboardView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Dashboard")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Summary Cards
                HStack(spacing: 16) {
                    summaryCard(
                        title: "Net Savings",
                        amount: summary.netSavings,
                        color: summary.netSavings >= 0 ? .green : .red
                    )
                    
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
                
                // Spending by Category
                VStack(alignment: .leading, spacing: 12) {
                    Text("Spending by Category")
                        .font(.headline)
                    
                    if summary.categoryBreakdown.isEmpty {
                        Text("No expenses this month")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(summary.categoryBreakdown.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                                HStack {
                                    Text(category.icon)
                                        .font(.title3)
                                    Text(category.rawValue)
                                        .frame(width: 150, alignment: .leading)
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.2))
                                            
                                            let percentage = summary.totalExpenses > 0 ? Double(truncating: (amount / summary.totalExpenses) as NSDecimalNumber) : 0
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.blue.opacity(0.6))
                                                .frame(width: geometry.size.width * min(percentage, 1.0))
                                        }
                                    }
                                    .frame(height: 20)
                                    
                                    Text("$\(amount, specifier: "%.2f")")
                                        .frame(width: 90, alignment: .trailing)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
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
        .cornerRadius(8)
    }
}

// MARK: - Transactions View (macOS)
struct MacTransactionsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddTransaction = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Transactions")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showingAddTransaction = true }) {
                    Label("Add Transaction", systemImage: "plus.circle.fill")
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // Transactions List
            if financeManager.transactions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Transactions")
                        .font(.headline)
                    Text("Add your first transaction to get started")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Table(financeManager.transactions.sorted(by: { $0.date > $1.date })) {
                    TableColumn("Date", value: \.date) { transaction in
                        Text(formatDate(transaction.date))
                            .font(.subheadline)
                    }
                    
                    TableColumn("Title", value: \.title) { transaction in
                        HStack(spacing: 8) {
                            Text(transaction.category.icon)
                            Text(transaction.title)
                        }
                    }
                    
                    TableColumn("Category", value: \.category.rawValue) { transaction in
                        Text(transaction.category.rawValue)
                            .font(.subheadline)
                    }
                    
                    TableColumn("Amount", value: \.amount) { transaction in
                        Text("\(transaction.isExpense ? "-" : "+")$\(transaction.amount, specifier: "%.2f")")
                            .fontWeight(.semibold)
                            .foregroundColor(transaction.isExpense ? .red : .green)
                    }
                }
                .contextMenu(forSelectionType: Transaction.ID.self) { indices in
                    Button(role: .destructive) {
                        for id in indices {
                            Task {
                                await financeManager.deleteTransaction(id)
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            MacAddTransactionView()
                .environmentObject(financeManager)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Add Transaction View (macOS)
struct MacAddTransactionView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var category: TransactionCategory = .other
    @State private var notes: String = ""
    @State private var isExpense: Bool = true
    @State private var date: Date = Date()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Transaction")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Section("Transaction Details") {
                    HStack {
                        Text("Title:")
                            .frame(width: 100, alignment: .leading)
                        TextField("Enter title", text: $title)
                    }
                    
                    HStack {
                        Text("Amount:")
                            .frame(width: 100, alignment: .leading)
                        HStack {
                            Text("$")
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    HStack {
                        Text("Category:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { cat in
                                Text(cat.icon + " " + cat.rawValue)
                                    .tag(cat)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Text("Date:")
                            .frame(width: 100, alignment: .leading)
                        DatePicker("", selection: $date, displayedComponents: .date)
                    }
                    
                    HStack {
                        Text("Type:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $isExpense) {
                            Text("Expense").tag(true)
                            Text("Income").tag(false)
                        }
                        .pickerStyle(.radioGroup)
                        .horizontalRadioGroupLayout()
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
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
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .padding()
        .frame(width: 500)
    }
}

// MARK: - Budgets View (macOS)
struct MacBudgetsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddBudget = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Budgets")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { showingAddBudget = true }) {
                    Label("Add Budget", systemImage: "plus.circle.fill")
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            if financeManager.budgets.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "target")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("No Budgets")
                        .font(.headline)
                    Text("Set spending limits for each category")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(financeManager.budgets) { budget in
                            if let status = financeManager.getBudgetStatus(for: budget.category) {
                                MacBudgetCard(status: status)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            MacAddBudgetView()
                .environmentObject(financeManager)
        }
    }
}

// MARK: - Budget Card (macOS)
struct MacBudgetCard: View {
    let status: BudgetStatus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(status.category.icon)
                            .font(.title2)
                        Text(status.category.rawValue)
                            .font(.headline)
                    }
                    Text("$\(status.spent, specifier: "%.2f") / $\(status.budget, specifier: "%.2f")")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\((status.percentageUsed * 100).rounded(toPlaces: 0), specifier: "%.0f")%")
                        .fontWeight(.semibold)
                    Text("$\(status.remaining, specifier: "%.2f") remaining")
                        .font(.caption)
                        .foregroundColor(status.isOverBudget ? .red : .green)
                }
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
        }
        .padding()
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Add Budget View (macOS)
struct MacAddBudgetView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) var dismiss
    
    @State private var category: TransactionCategory = .food
    @State private var limit: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Budget")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                Section("Budget Details") {
                    HStack {
                        Text("Category:")
                            .frame(width: 100, alignment: .leading)
                        Picker("", selection: $category) {
                            ForEach(TransactionCategory.allCases, id: \.self) { cat in
                                Text(cat.icon + " " + cat.rawValue)
                                    .tag(cat)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack {
                        Text("Monthly Limit:")
                            .frame(width: 100, alignment: .leading)
                        HStack {
                            Text("$")
                            TextField("0.00", text: $limit)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
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
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .padding()
        .frame(width: 450)
    }
}

#Preview {
    MacContentView()
        .environmentObject(FinanceManager())
}
