import SwiftUI

struct TaxCalculatorView: View {
    @State private var grossIncome: String = ""
    @State private var deductions: String = ""
    @State private var taxRate: String = ""
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    inputSection
                    
                    calculateButton
                    
                    if showingResults {
                        resultsSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Tax Calculator")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.red.opacity(0.2), .orange.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Tax Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Calculate your income tax and net income")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Gross Income",
                placeholder: "Enter annual income",
                text: $grossIncome,
                icon: "dollarsign.circle.fill",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Deductions",
                placeholder: "Enter deductions",
                text: $deductions,
                icon: "minus.circle.fill",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Tax Rate (%)",
                placeholder: "Enter tax rate",
                text: $taxRate,
                icon: "percent",
                keyboardType: .decimalPad
            )
        }
    }
    
    private var calculateButton: some View {
        Button(action: calculateTax) {
            HStack {
                Image(systemName: "doc.text.fill")
                Text("Calculate")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.red, .orange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(!canCalculate)
    }
    
    private var resultsSection: some View {
        VStack(spacing: 16) {
            Text("Tax Summary")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ResultCard(
                    title: "Taxable Income",
                    value: calculatedResults.taxableIncome,
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                ResultCard(
                    title: "Tax Amount",
                    value: calculatedResults.taxAmount,
                    color: .red,
                    icon: "minus.circle.fill"
                )
                
                ResultCard(
                    title: "Net Income",
                    value: calculatedResults.netIncome,
                    color: .green,
                    icon: "plus.circle.fill"
                )
                
                ResultCard(
                    title: "Effective Rate",
                    value: calculatedResults.effectiveRate,
                    color: .orange,
                    icon: "percent.circle.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var canCalculate: Bool {
        !grossIncome.isEmpty && !taxRate.isEmpty &&
        Double(grossIncome) != nil && Double(taxRate) != nil
    }
    
    private var calculatedResults: (taxableIncome: Double, taxAmount: Double, netIncome: Double, effectiveRate: Double) {
        guard let gross = Double(grossIncome),
              let deductionsValue = Double(deductions.isEmpty ? "0" : deductions),
              let rate = Double(taxRate) else {
            return (0, 0, 0, 0)
        }
        
        let taxableIncome = max(0, gross - deductionsValue)
        let taxAmount = taxableIncome * (rate / 100)
        let netIncome = gross - taxAmount
        let effectiveRate = (taxAmount / gross) * 100
        
        return (taxableIncome, taxAmount, netIncome, effectiveRate)
    }
    
    private func calculateTax() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingResults = true
        }
    }
}

#Preview {
    TaxCalculatorView()
} 