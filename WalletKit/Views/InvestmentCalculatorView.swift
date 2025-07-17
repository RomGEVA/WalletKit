import SwiftUI

struct InvestmentCalculatorView: View {
    @State private var initialInvestment: String = ""
    @State private var monthlyContribution: String = ""
    @State private var annualReturn: String = ""
    @State private var years: String = ""
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
            .navigationTitle("Investment Calculator")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                Text("Investment Calculator")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Calculate your investment returns and future value")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var inputSection: some View {
        VStack(spacing: 20) {
            InputField(
                title: "Initial Investment",
                placeholder: "Enter amount",
                text: $initialInvestment,
                icon: "dollarsign.circle.fill",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Monthly Contribution",
                placeholder: "Enter amount",
                text: $monthlyContribution,
                icon: "plus.circle.fill",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Annual Return (%)",
                placeholder: "Enter percentage",
                text: $annualReturn,
                icon: "percent",
                keyboardType: .decimalPad
            )
            
            InputField(
                title: "Investment Period (Years)",
                placeholder: "Enter years",
                text: $years,
                icon: "calendar",
                keyboardType: .numberPad
            )
        }
    }
    
    private var calculateButton: some View {
        Button(action: calculateInvestment) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                Text("Calculate")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
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
            Text("Investment Summary")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ResultCard(
                    title: "Total Invested",
                    value: calculatedResults.totalInvested,
                    color: .blue,
                    icon: "dollarsign.circle.fill"
                )
                
                ResultCard(
                    title: "Total Returns",
                    value: calculatedResults.totalReturns,
                    color: .green,
                    icon: "arrow.up.circle.fill"
                )
                
                ResultCard(
                    title: "Future Value",
                    value: calculatedResults.futureValue,
                    color: .purple,
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                ResultCard(
                    title: "Annual Growth",
                    value: calculatedResults.annualGrowth,
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
        !initialInvestment.isEmpty && !annualReturn.isEmpty && !years.isEmpty &&
        Double(initialInvestment) != nil && Double(annualReturn) != nil && Double(years) != nil
    }
    
    private var calculatedResults: (totalInvested: Double, totalReturns: Double, futureValue: Double, annualGrowth: Double) {
        guard let initial = Double(initialInvestment),
              let monthly = Double(monthlyContribution.isEmpty ? "0" : monthlyContribution),
              let rate = Double(annualReturn),
              let yearsValue = Double(years) else {
            return (0, 0, 0, 0)
        }
        
        let monthlyRate = rate / 100 / 12
        let numberOfMonths = yearsValue * 12
        
        // Future value formula: FV = P(1+r)^n + PMT * ((1+r)^n - 1) / r
        let futureValue = initial * pow(1 + monthlyRate, numberOfMonths) + 
                         monthly * (pow(1 + monthlyRate, numberOfMonths) - 1) / monthlyRate
        
        let totalInvested = initial + (monthly * numberOfMonths)
        let totalReturns = futureValue - totalInvested
        let annualGrowth = (futureValue / totalInvested - 1) * 100
        
        return (totalInvested, totalReturns, futureValue, annualGrowth)
    }
    
    private func calculateInvestment() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingResults = true
        }
    }
}

#Preview {
    InvestmentCalculatorView()
} 