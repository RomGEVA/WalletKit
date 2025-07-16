
import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddTransaction = false
    @State private var searchText = ""
    @State private var selectedFilter: TransactionFilter = .all
    @State private var showingFilterSheet = false
    
    enum TransactionFilter: String, CaseIterable {
        case all = "All"
        case income = "Income"
        case expense = "Expense"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
    }
    
    var filteredTransactions: [Transaction] {
        var transactions = financeManager.transactions
        
        // Apply search filter
        if !searchText.isEmpty {
            transactions = transactions.filter { transaction in
                transaction.note.localizedCaseInsensitiveContains(searchText) ||
                transaction.category.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply type filter
        switch selectedFilter {
        case .income:
            transactions = transactions.filter { $0.type == .income }
        case .expense:
            transactions = transactions.filter { $0.type == .expense }
        case .today:
            transactions = transactions.filter { Calendar.current.isDateInToday($0.date) }
        case .thisWeek:
            transactions = transactions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear) }
        case .thisMonth:
            transactions = transactions.filter { Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        case .all:
            break
        }
        
        return transactions.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                searchAndFilterBar
                
                if filteredTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionsList
                }
            }
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTransaction = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.mint)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
                .environmentObject(financeManager)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterView(selectedFilter: $selectedFilter)
        }
    }
    
    private var searchAndFilterBar: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search transactions...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Filter Button
            HStack {
                Button(action: { showingFilterSheet = true }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedFilter.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Text("\(filteredTransactions.count) transactions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    private var transactionsList: some View {
        List {
            ForEach(groupedTransactions.keys.sorted().reversed(), id: \.self) { date in
                Section(header: TransactionDateHeader(date: date)) {
                    ForEach(groupedTransactions[date] ?? []) { transaction in
                        TransactionRowView(transaction: transaction)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) {
                                    financeManager.deleteTransaction(transaction)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "list.bullet")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Transactions")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(searchText.isEmpty ? "Add your first transaction to get started" : "No transactions match your search")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button(action: { showingAddTransaction = true }) {
                    Text("Add Transaction")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.mint)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
}

// MARK: - Component Views
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: transaction.category)
            TransactionDetails(transaction: transaction)
            Spacer()
            TransactionAmount(transaction: transaction)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private struct CategoryIcon: View {
    let category: Category
    @ScaledMetric private var iconSize: CGFloat = 16
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.fromString(category.color))
                .frame(width: 40, height: 40)
            
            Image(systemName: category.icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

private struct TransactionDetails: View {
    let transaction: Transaction
    @ScaledMetric private var titleSize: CGFloat = 16

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(transaction.note.isEmpty ? transaction.category.name : transaction.note)
                .font(.system(size: titleSize, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            HStack {
                Text(transaction.category.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if transaction.isRecurring {
                    Image(systemName: "repeat")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

private struct TransactionAmount: View {
    let transaction: Transaction
    @ScaledMetric private var amountSize: CGFloat = 16

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(CurrencyFormatter.shared.format(transaction.amount))
                .font(.system(size: amountSize, weight: .semibold))
                .foregroundColor(transaction.type.color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(formatDate(transaction.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct TransactionDateHeader: View {
    let date: Date
    
    var body: some View {
        Text(formattedDate)
            .font(.headline)
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(.vertical, 4)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

struct FilterView: View {
    @Binding var selectedFilter: TransactionsView.TransactionFilter
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TransactionsView.TransactionFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        dismiss()
                    }) {
                        HStack {
                            Text(filter.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.mint)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    TransactionsView()
        .environmentObject(FinanceManager())
} 
