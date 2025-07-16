

import Foundation
import SwiftUI

// MARK: - Transaction Model
struct Transaction: Identifiable, Codable {
    let id = UUID()
    var amount: Double
    var category: Category
    var date: Date
    var note: String
    var type: TransactionType
    var isRecurring: Bool
    var recurringInterval: RecurringInterval?
    
    enum TransactionType: String, CaseIterable, Codable {
        case income = "Income"
        case expense = "Expense"
        
        var color: Color {
            switch self {
            case .income:
                return .green
            case .expense:
                return .red
            }
        }
        
        var icon: String {
            switch self {
            case .income:
                return "arrow.down.circle.fill"
            case .expense:
                return "arrow.up.circle.fill"
            }
        }
    }
    
    enum RecurringInterval: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
}

// MARK: - Category Model
struct Category: Identifiable, Codable, Hashable {
    let id = UUID()
    var name: String
    var icon: String
    var color: String
    var type: Transaction.TransactionType
    
    static let defaultCategories: [Category] = [
        // Income categories
        Category(name: "Salary", icon: "dollarsign.circle.fill", color: "green", type: .income),
        Category(name: "Freelance", icon: "laptopcomputer", color: "blue", type: .income),
        Category(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: "purple", type: .income),
        Category(name: "Gift", icon: "gift.fill", color: "pink", type: .income),
        Category(name: "Business", icon: "briefcase.fill", color: "brown", type: .income),
        Category(name: "Rental Income", icon: "house.fill", color: "cyan", type: .income),
        Category(name: "Other", icon: "ellipsis.circle.fill", color: "gray", type: .income),
        
        // Expense categories
        Category(name: "Groceries", icon: "cart.fill", color: "green", type: .expense),
        Category(name: "Food", icon: "fork.knife", color: "orange", type: .expense),
        Category(name: "Transport", icon: "car.fill", color: "blue", type: .expense),
        Category(name: "Shopping", icon: "bag.fill", color: "purple", type: .expense),
        Category(name: "Entertainment", icon: "tv.fill", color: "pink", type: .expense),
        Category(name: "Health", icon: "cross.fill", color: "red", type: .expense),
        Category(name: "Subscriptions", icon: "arrow.2.circlepath", color: "indigo", type: .expense),
        Category(name: "Travel", icon: "airplane", color: "teal", type: .expense),
        Category(name: "Pets", icon: "pawprint.fill", color: "brown", type: .expense),
        Category(name: "Education", icon: "book.fill", color: "indigo", type: .expense),
        Category(name: "Bills", icon: "doc.text.fill", color: "gray", type: .expense),
        Category(name: "Home", icon: "house.fill", color: "brown", type: .expense),
        Category(name: "Other", icon: "ellipsis.circle.fill", color: "gray", type: .expense)
    ]
}

// MARK: - Budget Model
struct Budget: Identifiable, Codable {
    let id = UUID()
    var category: Category
    var amount: Double
    var spent: Double
    var period: BudgetPeriod
    var startDate: Date
    
    enum BudgetPeriod: String, CaseIterable, Codable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
    var remaining: Double {
        amount - spent
    }
    
    var progress: Double {
        guard amount > 0 else { return 0 }
        return min(spent / amount, 1.0)
    }
    
    var isOverBudget: Bool {
        spent > amount
    }
}

// MARK: - Financial Summary
struct FinancialSummary {
    var totalIncome: Double
    var totalExpenses: Double
    var netAmount: Double
    var monthlyIncome: Double
    var monthlyExpenses: Double
    var monthlyNet: Double
    
    init(transactions: [Transaction]) {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        let monthlyTransactions = transactions.filter { transaction in
            let transactionMonth = Calendar.current.component(.month, from: transaction.date)
            let transactionYear = Calendar.current.component(.year, from: transaction.date)
            return transactionMonth == currentMonth && transactionYear == currentYear
        }
        
        totalIncome = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        totalExpenses = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        netAmount = totalIncome - totalExpenses
        
        monthlyIncome = monthlyTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        monthlyExpenses = monthlyTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        monthlyNet = monthlyIncome - monthlyExpenses
    }
}

// MARK: - Analytics Data
struct CategoryAnalytics {
    let category: Category
    let totalAmount: Double
    let transactionCount: Int
    let percentage: Double
}

struct MonthlyAnalytics {
    let month: String
    let income: Double
    let expenses: Double
    let net: Double
} 
