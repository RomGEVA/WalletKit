//


import SwiftUI

struct AddBudgetView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var selectedCategory: Category?
    @State private var selectedPeriod: Budget.BudgetPeriod = .monthly
    @State private var showingCategoryPicker = false
    
    private var isValidForm: Bool {
        !amount.isEmpty &&
        Double(amount) != nil &&
        Double(amount)! > 0 &&
        selectedCategory != nil
    }
    
    private var availableCategories: [Category] {
        financeManager.categories.filter { $0.type == .expense }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Budget Amount") {
                    HStack {
                        Text("$")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                            .fontWeight(.medium)
                    }
                }
                
                Section("Category") {
                    if let selectedCategory = selectedCategory {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.fromString(selectedCategory.color))
                                    .frame(width: 32, height: 32)
                                
                                Image(systemName: selectedCategory.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Text(selectedCategory.name)
                                .font(.body)
                            
                            Spacer()
                            
                            Button("Change") {
                                showingCategoryPicker = true
                            }
                            .foregroundColor(.mint)
                        }
                    } else {
                        Button(action: { showingCategoryPicker = true }) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.mint)
                                Text("Select Category")
                                    .foregroundColor(.mint)
                            }
                        }
                    }
                }
                
                Section("Budget Period") {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(Budget.BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Budget Information")
                                .font(.headline)
                        }
                        
                        Text("• Budgets help you track spending in specific categories")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• You'll receive notifications when approaching your limit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Budgets automatically reset at the end of each period")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Add Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveBudget()
                    }
                    .disabled(!isValidForm)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            BudgetCategoryPickerView(
                categories: availableCategories,
                selectedCategory: $selectedCategory
            )
        }
    }
    
    private func saveBudget() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        let budget = Budget(
            category: category,
            amount: amountValue,
            spent: 0,
            period: selectedPeriod,
            startDate: Date()
        )
        
        financeManager.addBudget(budget)
        dismiss()
    }
}

struct BudgetCategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(Color.fromString(category.color))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: category.icon)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Text(category.name)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategory?.id == category.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.mint)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddBudgetView()
        .environmentObject(FinanceManager())
} 
