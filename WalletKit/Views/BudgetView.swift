//
//  BudgetView.swift


import SwiftUI

struct BudgetView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var showingAddBudget = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    budgetOverviewSection
                    
                    budgetListSection
                }
                .padding()
            }
            .navigationTitle("Budget")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddBudget = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.mint)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            AddBudgetView()
                .environmentObject(financeManager)
        }
    }
    
    private var budgetOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Budget Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            let totalBudget = financeManager.budgets.reduce(0) { $0 + $1.amount }
            let totalSpent = financeManager.budgets.reduce(0) { $0 + $1.spent }
            let totalRemaining = totalBudget - totalSpent
            let overallProgress = totalBudget > 0 ? totalSpent / totalBudget : 0
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                BudgetOverviewCard(
                    title: "Total Budget",
                    amount: totalBudget,
                    color: .blue,
                    icon: "target"
                )
                
                BudgetOverviewCard(
                    title: "Total Spent",
                    amount: totalSpent,
                    color: .red,
                    icon: "creditcard.fill"
                )
                
                BudgetOverviewCard(
                    title: "Remaining",
                    amount: totalRemaining,
                    color: totalRemaining >= 0 ? .green : .orange,
                    icon: "banknote.fill"
                )
                
                BudgetOverviewCard(
                    title: "Progress",
                    percentage: overallProgress * 100,
                    color: overallProgress > 0.8 ? .red : overallProgress > 0.6 ? .orange : .green,
                    icon: "chart.pie.fill"
                )
            }
        }
    }
    
    private var budgetListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Budgets")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            if financeManager.budgets.isEmpty {
                EmptyStateView(
                    icon: "target",
                    title: "No Budgets",
                    message: "Create your first budget to start tracking your spending"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(financeManager.budgets) { budget in
                        BudgetRowView(budget: budget)
                    }
                }
            }
        }
    }
}

struct BudgetRowView: View {
    let budget: Budget
    @ScaledMetric private var iconSize: CGFloat = 16
    @ScaledMetric private var titleSize: CGFloat = 16
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.fromString(budget.category.color))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: budget.category.icon)
                        .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.category.name)
                        .font(.system(size: titleSize, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("\(budget.period.rawValue) Budget")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(CurrencyFormatter.shared.format(budget.spent))
                        .font(.system(size: titleSize, weight: .semibold))
                        .foregroundColor(budget.isOverBudget ? .red : .primary)
                    
                    Text("of \(CurrencyFormatter.shared.format(budget.amount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(budget.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(budget.isOverBudget ? .red : .secondary)
                    
                    Spacer()
                    
                    Text(CurrencyFormatter.shared.format(budget.remaining))
                        .font(.caption)
                        .foregroundColor(budget.remaining >= 0 ? .green : .red)
                }
                
                ProgressView(value: min(budget.progress, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: budget.isOverBudget ? .red : .mint))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct BudgetOverviewCard: View {
    let title: String
    let amount: Double?
    let percentage: Double?
    let color: Color
    let icon: String
    
    @ScaledMetric private var titleSize: CGFloat = 22
    
    init(title: String, amount: Double, color: Color, icon: String) {
        self.title = title
        self.amount = amount
        self.percentage = nil
        self.color = color
        self.icon = icon
    }
    
    init(title: String, percentage: Double, color: Color, icon: String) {
        self.title = title
        self.amount = nil
        self.percentage = percentage
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: titleSize, weight: .regular))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let amount = amount {
                    Text(CurrencyFormatter.shared.format(amount))
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else if let percentage = percentage {
                    Text("\(Int(percentage))%")
                        .font(.system(size: titleSize, weight: .bold))
                        .foregroundColor(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    BudgetView()
        .environmentObject(FinanceManager())
} 
