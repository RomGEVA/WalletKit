

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Binding var selectedTab: Int
    
    @State private var showingAddTransaction = false
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    financialOverviewSection
                    
                    recentTransactionsSection
                    
                    budgetStatusSection
                    
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Dashboard")
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
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .environmentObject(financeManager)
        }
    }
    
    private var financialOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Financial Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                FinancialCard(
                    title: "Monthly Income",
                    amount: financeManager.financialSummary.monthlyIncome,
                    color: .green,
                    icon: "arrow.down.circle.fill"
                )
                
                FinancialCard(
                    title: "Monthly Expenses",
                    amount: financeManager.financialSummary.monthlyExpenses,
                    color: .red,
                    icon: "arrow.up.circle.fill"
                )
                
                FinancialCard(
                    title: "Net Amount",
                    amount: financeManager.financialSummary.monthlyNet,
                    color: financeManager.financialSummary.monthlyNet >= 0 ? .mint : .orange,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                FinancialCard(
                    title: "Total Balance",
                    amount: financeManager.financialSummary.netAmount,
                    color: financeManager.financialSummary.netAmount >= 0 ? .blue : .red,
                    icon: "banknote.fill"
                )
            }
        }
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink("See All", destination: TransactionsView().environmentObject(financeManager))
                    .foregroundColor(.mint)
            }
            
            if financeManager.transactions.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "No Transactions",
                    message: "Add your first transaction to get started"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(financeManager.transactions.prefix(5))) { transaction in
                        TransactionRowView(transaction: transaction)
                    }
                }
            }
        }
    }
    
    private var budgetStatusSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Budget Status")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                NavigationLink("See All", destination: BudgetView().environmentObject(financeManager))
                    .foregroundColor(.mint)
            }
            
            if financeManager.budgets.isEmpty {
                EmptyStateView(
                    icon: "target",
                    title: "No Budgets",
                    message: "Create budgets to track your spending"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(financeManager.budgets.prefix(3))) { budget in
                        BudgetRowView(budget: budget)
                    }
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                QuickActionButton(
                    title: "Add Transaction",
                    icon: "plus",
                    color: .mint
                ) {
                    showingAddTransaction = true
                }
                
                QuickActionButton(
                    title: "Add Budget",
                    icon: "target",
                    color: .blue
                ) {
                    showingAddBudget = true
                }
                
                QuickActionButton(
                    title: "Analytics",
                    icon: "chart.pie.fill",
                    color: .purple
                ) {
                    selectedTab = 3
                }
                
                QuickActionButton(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray
                ) {
                    selectedTab = 4
                }
            }
        }
    }
}

struct FinancialCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @ScaledMetric var title2Size: CGFloat = 22
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: title2Size, weight: .regular))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(CurrencyFormatter.shared.format(amount))
                    .font(.system(size: title2Size, weight: .bold))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @ScaledMetric var iconSize: CGFloat = 20
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    DashboardView(selectedTab: .constant(0))
        .environmentObject(FinanceManager())
} 
