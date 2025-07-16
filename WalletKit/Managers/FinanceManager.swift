
import Foundation
import SwiftUI
import Combine

@MainActor
class FinanceManager: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var budgets: [Budget] = []
    @Published var categories: [Category] = []
    
    private let userDefaults = UserDefaults.standard
    private let transactionsKey = "transactions_v1"
    private let budgetsKey = "budgets_v1"
    private let categoriesKey = "categories_v1"
    
    init() {
        loadCategories()
        loadTransactions()
        loadBudgets()
    }
    
    // MARK: - Data Persistence
    private func loadTransactions() {
        if let data = userDefaults.data(forKey: transactionsKey) {
            if let decoded = try? JSONDecoder().decode([Transaction].self, from: data) {
                transactions = decoded
                return
            }
        }
        transactions = []
    }
    
    private func loadBudgets() {
        if let data = userDefaults.data(forKey: budgetsKey) {
            if let decoded = try? JSONDecoder().decode([Budget].self, from: data) {
                budgets = decoded
                return
            }
        }
        budgets = []
    }
    
    private func loadCategories() {
        if let data = userDefaults.data(forKey: categoriesKey) {
            if let decoded = try? JSONDecoder().decode([Category].self, from: data) {
                if !decoded.isEmpty {
                    categories = decoded
                    return
                }
            }
        }
        categories = Category.defaultCategories
        saveCategories()
    }
    
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            userDefaults.set(encoded, forKey: transactionsKey)
        }
    }
    
    private func saveBudgets() {
        if let encoded = try? JSONEncoder().encode(budgets) {
            userDefaults.set(encoded, forKey: budgetsKey)
        }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            userDefaults.set(encoded, forKey: categoriesKey)
        }
    }
    
    // MARK: - Transaction Management
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        updateBudgetForTransaction(transaction)
        saveTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        transactions.removeAll { $0.id == transaction.id }
        updateBudgetForDeletedTransaction(transaction)
        saveTransactions()
    }
    
    func updateTransaction(_ transaction: Transaction) {
        if let index = transactions.firstIndex(where: { $0.id == transaction.id }) {
            let oldTransaction = transactions[index]
            updateBudgetForDeletedTransaction(oldTransaction)
            
            transactions[index] = transaction
            updateBudgetForTransaction(transaction)
            saveTransactions()
        }
    }
    
    // MARK: - Budget Management
    func addBudget(_ budget: Budget) {
        budgets.append(budget)
        saveBudgets()
    }
    
    func deleteBudget(_ budget: Budget) {
        budgets.removeAll { $0.id == budget.id }
        saveBudgets()
    }
    
    func updateBudget(_ budget: Budget) {
        if let index = budgets.firstIndex(where: { $0.id == budget.id }) {
            budgets[index] = budget
            saveBudgets()
        }
    }
    
    private func updateBudgetForTransaction(_ transaction: Transaction) {
        guard transaction.type == .expense else { return }
        
        if let budgetIndex = budgets.firstIndex(where: { $0.category.id == transaction.category.id }) {
            budgets[budgetIndex].spent += transaction.amount
            saveBudgets()
        }
    }
    
    private func updateBudgetForDeletedTransaction(_ transaction: Transaction) {
        guard transaction.type == .expense else { return }
        
        if let budgetIndex = budgets.firstIndex(where: { $0.category.id == transaction.category.id }) {
            budgets[budgetIndex].spent -= transaction.amount
            saveBudgets()
        }
    }
    
    // MARK: - Category Management
    func addCategory(_ category: Category) {
        categories.append(category)
        saveCategories()
    }
    
    func deleteCategory(_ category: Category) {
        categories.removeAll { $0.id == category.id }
        saveCategories()
    }
    
    // MARK: - Analytics
    var financialSummary: FinancialSummary {
        FinancialSummary(transactions: transactions)
    }
    
    func getCategoryAnalytics() -> [CategoryAnalytics] {
        let expenseTransactions = transactions.filter { $0.type == .expense }
        let totalExpenses = expenseTransactions.reduce(0) { $0 + $1.amount }
        
        var categoryTotals: [UUID: Double] = [:]
        var categoryCounts: [UUID: Int] = [:]
        
        for transaction in expenseTransactions {
            categoryTotals[transaction.category.id, default: 0] += transaction.amount
            categoryCounts[transaction.category.id, default: 0] += 1
        }
        
        return categoryTotals.compactMap { categoryId, totalAmount in
            guard let category = categories.first(where: { $0.id == categoryId }) else { return nil }
            let percentage = totalExpenses > 0 ? (totalAmount / totalExpenses) * 100 : 0
            return CategoryAnalytics(
                category: category,
                totalAmount: totalAmount,
                transactionCount: categoryCounts[categoryId] ?? 0,
                percentage: percentage
            )
        }.sorted { $0.totalAmount > $1.totalAmount }
    }
    
    func getMonthlyAnalytics() -> [MonthlyAnalytics] {
        let calendar = Calendar.current
        let currentDate = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: currentDate) ?? currentDate
        
        var monthlyData: [String: (income: Double, expenses: Double)] = [:]
        
        for transaction in transactions {
            if transaction.date >= sixMonthsAgo {
                let monthKey = formatMonth(transaction.date)
                if monthlyData[monthKey] == nil {
                    monthlyData[monthKey] = (0, 0)
                }
                
                if transaction.type == .income {
                    monthlyData[monthKey]?.income += transaction.amount
                } else {
                    monthlyData[monthKey]?.expenses += transaction.amount
                }
            }
        }
        
        return monthlyData.map { month, data in
            MonthlyAnalytics(
                month: month,
                income: data.income,
                expenses: data.expenses,
                net: data.income - data.expenses
            )
        }.sorted { $0.month < $1.month }
    }
    
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        transactions = []
        budgets = []
        categories = Category.defaultCategories
        
        saveTransactions()
        saveBudgets()
        saveCategories()
    }
} 
