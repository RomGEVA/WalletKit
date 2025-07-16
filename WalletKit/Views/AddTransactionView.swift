//
//  AddTransactionView.swift
//  Wallest
//
//  Created by Denis on 20.06.2025.
//

import SwiftUI

struct AddTransactionView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var selectedCategory: Category?
    @State private var selectedType: Transaction.TransactionType = .expense
    @State private var note = ""
    @State private var date = Date()
    @State private var isRecurring = false
    @State private var selectedRecurringInterval: Transaction.RecurringInterval = .monthly
    @State private var showingCategoryPicker = false
    @Namespace private var namespace
    
    private var isValidForm: Bool {
        !amount.isEmpty && 
        Double(amount) != nil && 
        Double(amount)! > 0 && 
        selectedCategory != nil
    }
    
    private var filteredCategories: [Category] {
        financeManager.categories.filter { $0.type == selectedType }
    }
    
    var body: some View {
        NavigationView {
            Form {
                transactionTypePicker
                amountField
                categorySelector
                detailsSection
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValidForm)
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(
                categories: filteredCategories,
                selectedCategory: $selectedCategory
            )
        }
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let category = selectedCategory else { return }
        
        let transaction = Transaction(
            amount: amountValue,
            category: category,
            date: date,
            note: note,
            type: selectedType,
            isRecurring: isRecurring,
            recurringInterval: isRecurring ? selectedRecurringInterval : nil
        )
        
        financeManager.addTransaction(transaction)
        dismiss()
    }
}

// MARK: - Subviews
private extension AddTransactionView {
    var transactionTypePicker: some View {
        Section(header: Text("Transaction Type").padding(.leading, -16)) {
            TransactionTypePicker(selectedType: $selectedType, selectedCategory: $selectedCategory, namespace: namespace)
        }
        .textCase(nil)
    }
    
    var amountField: some View {
        Section("Amount") {
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
    }
    
    var categorySelector: some View {
        Section("Category") {
            if let selectedCategory = selectedCategory {
                HStack {
                    CategoryIconView(category: selectedCategory)
                    
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
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    var detailsSection: some View {
        Group {
            Section("Note (Optional)") {
                TextField("Add a note...", text: $note, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section("Date") {
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
            }
            
            Section("Recurring") {
                Toggle("Make this recurring", isOn: $isRecurring)
                
                if isRecurring {
                    Picker("Interval", selection: $selectedRecurringInterval) {
                        ForEach(Transaction.RecurringInterval.allCases, id: \.self) { interval in
                            Text(interval.rawValue).tag(interval)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }
}

// MARK: - Component Views
private struct TransactionTypePicker: View {
    @Binding var selectedType: Transaction.TransactionType
    @Binding var selectedCategory: Category?
    var namespace: Namespace.ID
    
    @ScaledMetric private var iconSize: CGFloat = 16
    @ScaledMetric private var textSize: CGFloat = 14

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Transaction.TransactionType.allCases, id: \.self) { type in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedType = type
                    }
                    selectedCategory = nil
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: type.icon)
                            .font(.system(size: iconSize, weight: .bold))
                            .foregroundColor(selectedType == type ? .white : .secondary)
                        
                        Text(type.rawValue)
                            .font(.system(size: textSize, weight: .semibold))
                            .foregroundColor(selectedType == type ? .white : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if selectedType == type {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(type.color)
                                    .matchedGeometryEffect(id: "picker", in: namespace)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .listRowInsets(EdgeInsets())
    }
}

private struct CategoryIconView: View {
    let category: Category
    @ScaledMetric private var iconSize: CGFloat = 14
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.fromString(category.color))
                .frame(width: 32, height: 32)
            
            Image(systemName: category.icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.white)
        }
    }
}

struct CategoryPickerView: View {
    let categories: [Category]
    @Binding var selectedCategory: Category?
    @Environment(\.dismiss) private var dismiss
    
    @ScaledMetric private var circleSize: CGFloat = 40
    @ScaledMetric private var iconSize: CGFloat = 18
    
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
                                    .frame(width: circleSize, height: circleSize)
                                
                                Image(systemName: category.icon)
                                    .font(.system(size: iconSize, weight: .medium))
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
    AddTransactionView()
        .environmentObject(FinanceManager())
} 