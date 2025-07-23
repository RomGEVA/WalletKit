import SwiftUI

struct MoreView: View {
    @State private var showingCalculator = false
    @State private var showingConverter = false
    @State private var showingInvestmentCalculator = false
    @State private var showingTaxCalculator = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    toolsSection
                    
                    additionalFeaturesSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))
        }
        .sheet(isPresented: $showingCalculator) {
            CreditCalculatorView()
        }
        .sheet(isPresented: $showingConverter) {
            CurrencyConverterView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingInvestmentCalculator) {
            InvestmentCalculatorView()
        }
        .sheet(isPresented: $showingTaxCalculator) {
            TaxCalculatorView()
        }
        .onChange(of: showingCalculator) { newValue in
            print("showingCalculator changed to: \(newValue)")
        }
        .onChange(of: showingConverter) { newValue in
            print("showingConverter changed to: \(newValue)")
        }
        .onChange(of: showingSettings) { newValue in
            print("showingSettings changed to: \(newValue)")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.2), .pink.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "ellipsis.circle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.purple)
            }
            
            VStack(spacing: 8) {
                Text("More Tools")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Additional financial tools and features")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Financial Tools")
                .font(.title3)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ToolCard(
                    title: "Credit Calculator",
                    subtitle: "Calculate loan payments",
                    icon: "function",
                    color: .orange
                ) {
                    print("Credit Calculator tapped")
                    showingCalculator = true
                }
                
                ToolCard(
                    title: "Currency Converter",
                    subtitle: "Convert between currencies",
                    icon: "arrow.left.arrow.right",
                    color: .green
                ) {
                    print("Currency Converter tapped")
                    showingConverter = true
                }
                
                ToolCard(
                    title: "Investment Calculator",
                    subtitle: "Calculate returns",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                ) {
                    print("Investment Calculator tapped")
                    showingInvestmentCalculator = true
                }
                
                ToolCard(
                    title: "Tax Calculator",
                    subtitle: "Estimate taxes",
                    icon: "doc.text.fill",
                    color: .red
                ) {
                    print("Tax Calculator tapped")
                    showingTaxCalculator = true
                }
            }
        }
    }
    
    private var additionalFeaturesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Features")
                .font(.title3)
                .fontWeight(.bold)
            
            NavigationLink(destination: GoalsView()) {
                HStack {
                    Image(systemName: "flag.fill")
                        .foregroundColor(.blue)
                    Text("Financial Goals")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            
            NavigationLink(destination: AchievementsView()) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Achievements")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
}

struct ToolCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            print("ToolCard tapped: \(title)")
            action()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MoreView()
} 