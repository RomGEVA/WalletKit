import SwiftUI

struct CreditCalculatorView: View {
    @State private var loanAmount: String = ""
    @State private var interestRate: String = ""
    @State private var loanTerm: String = ""
    @State private var selectedTermType: TermType = .years
    @State private var selectedPaymentType: PaymentType = .monthly
    @State private var showingResults = false
    
    enum TermType: String, CaseIterable {
        case years = "Years"
        case months = "Months"
    }
    
    enum PaymentType: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
    }
    
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
            .navigationTitle("Credit Calculator")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.mint.opacity(0.2), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "function")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.mint)
            }
            
            VStack(spacing: 8) {
                Text("Credit Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Calculate your loan payments and interest")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Loan Amount",
                placeholder: "Enter amount",
                text: $loanAmount,
                icon: "dollarsign.circle.fill",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Interest Rate (%)",
                placeholder: "Enter rate",
                text: $interestRate,
                icon: "percent",
                keyboardType: .decimalPad
            )
            
            HStack(spacing: 16) {
                InputField(
                    title: "Loan Term",
                    placeholder: "Enter term",
                    text: $loanTerm,
                    icon: "calendar",
                    keyboardType: .numberPad
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Term Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Term Type", selection: $selectedTermType) {
                        ForEach(TermType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Payment Frequency")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Payment Type", selection: $selectedPaymentType) {
                    ForEach(PaymentType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
    
    private var calculateButton: some View {
        Button(action: calculateLoan) {
            HStack {
                Image(systemName: "function")
                Text("Calculate")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.mint, .blue],
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
            Text("Loan Summary")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ResultCard(
                    title: "Monthly Payment",
                    value: calculatedResults.monthlyPayment,
                    color: .mint,
                    icon: "calendar.badge.clock"
                )
                
                ResultCard(
                    title: "Total Interest",
                    value: calculatedResults.totalInterest,
                    color: .orange,
                    icon: "percent.circle.fill"
                )
                
                ResultCard(
                    title: "Total Payment",
                    value: calculatedResults.totalPayment,
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                ResultCard(
                    title: "Loan Term",
                    value: calculatedResults.loanTerm,
                    color: .purple,
                    icon: "clock.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var canCalculate: Bool {
        !loanAmount.isEmpty && !interestRate.isEmpty && !loanTerm.isEmpty &&
        Double(loanAmount) != nil && Double(interestRate) != nil && Double(loanTerm) != nil
    }
    
    private var calculatedResults: (monthlyPayment: Double, totalInterest: Double, totalPayment: Double, loanTerm: Double) {
        guard let amount = Double(loanAmount),
              let rate = Double(interestRate),
              let term = Double(loanTerm) else {
            return (0, 0, 0, 0)
        }
        
        let monthlyRate = rate / 100 / 12
        let numberOfPayments = selectedTermType == .years ? term * 12 : term
        
        let monthlyPayment = amount * (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / (pow(1 + monthlyRate, numberOfPayments) - 1)
        let totalPayment = monthlyPayment * numberOfPayments
        let totalInterest = totalPayment - amount
        
        return (monthlyPayment, totalInterest, totalPayment, numberOfPayments)
    }
    
    private func calculateLoan() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingResults = true
        }
    }
}

struct InputField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.mint)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct ResultCard: View {
    let title: String
    let value: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatValue())
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func formatValue() -> String {
        if title.contains("Payment") || title.contains("Interest") {
            return CurrencyFormatter.shared.format(value)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

#Preview {
    CreditCalculatorView()
} 