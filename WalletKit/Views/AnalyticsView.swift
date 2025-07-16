

import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @State private var selectedTimeRange: TimeRange = .month
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    timeRangeSelector
                    
                    spendingOverviewSection
                    
                    categoryBreakdownSection
                    
                    monthlyTrendsSection
                    
                    insightsSection
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeRangeSelector: some View {
        HStack {
            Text("Time Range")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
            
            Picker("Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .frame(width: 200)
        }
    }
    
    private var spendingOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Spending Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalyticsCard(
                    title: "Total Income",
                    amount: financeManager.financialSummary.totalIncome,
                    color: .green,
                    icon: "arrow.down.circle.fill"
                )
                
                AnalyticsCard(
                    title: "Total Expenses",
                    amount: financeManager.financialSummary.totalExpenses,
                    color: .red,
                    icon: "arrow.up.circle.fill"
                )
                
                AnalyticsCard(
                    title: "Net Savings",
                    amount: financeManager.financialSummary.netAmount,
                    color: financeManager.financialSummary.netAmount >= 0 ? .mint : .orange,
                    icon: "banknote.fill"
                )
                
                AnalyticsCard(
                    title: "Savings Rate",
                    percentage: calculateSavingsRate(),
                    color: .blue,
                    icon: "percent"
                )
            }
        }
    }
    
    private var categoryBreakdownSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Category Breakdown")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            let categoryAnalytics = financeManager.getCategoryAnalytics()
            
            if categoryAnalytics.isEmpty {
                EmptyStateView(
                    icon: "chart.pie.fill",
                    title: "No Data",
                    message: "Add some transactions to see spending breakdown"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(categoryAnalytics.prefix(5)), id: \.category.id) { analytics in
                        CategoryAnalyticsRow(analytics: analytics)
                    }
                }
            }
        }
    }
    
    private var monthlyTrendsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monthly Trends")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            let monthlyData = financeManager.getMonthlyAnalytics()
            
            if monthlyData.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "No Data",
                    message: "Add transactions over time to see trends"
                )
            } else {
                Chart(monthlyData, id: \.month) { data in
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Income", data.income)
                    )
                    .foregroundStyle(.green)
                    .symbol(Circle())
                    
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Expenses", data.expenses)
                    )
                    .foregroundStyle(.red)
                    .symbol(Circle())
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartLegend(position: .bottom)
            }
        }
    }
    
    private var insightsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Financial Insights")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                InsightCard(
                    title: "Top Spending Category",
                    value: getTopSpendingCategory(),
                    icon: "chart.bar.fill",
                    color: .red
                )
                
                InsightCard(
                    title: "Average Daily Spending",
                    value: CurrencyFormatter.shared.format(calculateAverageDailySpending()),
                    icon: "calendar",
                    color: .blue
                )
                
                InsightCard(
                    title: "Best Saving Month",
                    value: getBestSavingMonth(),
                    icon: "star.fill",
                    color: .green
                )
            }
        }
    }
    
    private func calculateSavingsRate() -> Double {
        let income = financeManager.financialSummary.totalIncome
        let expenses = financeManager.financialSummary.totalExpenses
        
        guard income > 0 else { return 0 }
        return ((income - expenses) / income) * 100
    }
    
    private func calculateAverageDailySpending() -> Double {
        let expenses = financeManager.financialSummary.totalExpenses
        let daysSinceFirstTransaction = calculateDaysSinceFirstTransaction()
        return daysSinceFirstTransaction > 0 ? expenses / Double(daysSinceFirstTransaction) : 0
    }
    
    private func calculateDaysSinceFirstTransaction() -> Int {
        guard let firstTransaction = financeManager.transactions.min(by: { $0.date < $1.date }) else {
            return 1
        }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: firstTransaction.date, to: Date()).day ?? 1
        return max(days, 1)
    }
    
    private func getTopSpendingCategory() -> String {
        let categoryAnalytics = financeManager.getCategoryAnalytics()
        return categoryAnalytics.first?.category.name ?? "No data"
    }
    
    private func getBestSavingMonth() -> String {
        let monthlyData = financeManager.getMonthlyAnalytics()
        let bestMonth = monthlyData.max(by: { $0.net < $1.net })
        return bestMonth?.month ?? "No data"
    }
}

struct AnalyticsCard: View {
    let title: String
    let amount: Double?
    let percentage: Double?
    let color: Color
    let icon: String
    
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
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let amount = amount {
                    Text(CurrencyFormatter.shared.format(amount))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                } else if let percentage = percentage {
                    Text("\(Int(percentage))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct CategoryAnalyticsRow: View {
    let analytics: CategoryAnalytics
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: analytics.category.icon)
                    .foregroundColor(Color.fromString(analytics.category.color))
                
                Text(analytics.category.name)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(CurrencyFormatter.shared.format(analytics.totalAmount))
                    .fontWeight(.semibold)
                
                Text("\(Int(analytics.percentage))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .trailing)
            }
            
            ProgressView(value: analytics.percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.fromString(analytics.category.color)))
                .scaleEffect(x: 1, y: 1.5, anchor: .center)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(FinanceManager())
} 
