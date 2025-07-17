import SwiftUI

struct CurrencyConverterView: View {
    @State private var amount: String = "1"
    @State private var fromCurrency: Currency = .usd
    @State private var toCurrency: Currency = .eur
    @State private var isConverting = false
    @State private var convertedAmount: Double = 0
    @State private var exchangeRate: Double = 0
    @State private var lastUpdated: Date = Date()
    
    enum Currency: String, CaseIterable {
        case usd = "USD"
        case eur = "EUR"
        case gbp = "GBP"
        case jpy = "JPY"
        case cad = "CAD"
        case aud = "AUD"
        case chf = "CHF"
        case cny = "CNY"
        case rub = "RUB"
        case krw = "KRW"
        
        var symbol: String {
            switch self {
            case .usd: return "$"
            case .eur: return "€"
            case .gbp: return "£"
            case .jpy: return "¥"
            case .cad: return "C$"
            case .aud: return "A$"
            case .chf: return "CHF"
            case .cny: return "¥"
            case .rub: return "₽"
            case .krw: return "₩"
            }
        }
        
        var name: String {
            switch self {
            case .usd: return "US Dollar"
            case .eur: return "Euro"
            case .gbp: return "British Pound"
            case .jpy: return "Japanese Yen"
            case .cad: return "Canadian Dollar"
            case .aud: return "Australian Dollar"
            case .chf: return "Swiss Franc"
            case .cny: return "Chinese Yuan"
            case .rub: return "Russian Ruble"
            case .krw: return "South Korean Won"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    conversionSection
                    
                    currencySelectionSection
                    
                    if convertedAmount > 0 {
                        resultSection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Currency Converter")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemBackground))
            .onAppear {
                convertCurrency()
            }
            .onChange(of: amount) { _ in
                convertCurrency()
            }
            .onChange(of: fromCurrency) { _ in
                convertCurrency()
            }
            .onChange(of: toCurrency) { _ in
                convertCurrency()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.green.opacity(0.2), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.green)
            }
            
            VStack(spacing: 8) {
                Text("Currency Converter")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Convert between different currencies")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private var conversionSection: some View {
        VStack(spacing: 16) {
            Text("Amount")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                TextField("0", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title)
                    .fontWeight(.bold)
                    .textFieldStyle(PlainTextFieldStyle())
                
                Text(fromCurrency.symbol)
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var currencySelectionSection: some View {
        VStack(spacing: 20) {
            CurrencyPicker(
                title: "From",
                selectedCurrency: $fromCurrency,
                isFrom: true
            )
            
            Button(action: swapCurrencies) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
                    .foregroundColor(.mint)
                    .frame(width: 44, height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            
            CurrencyPicker(
                title: "To",
                selectedCurrency: $toCurrency,
                isFrom: false
            )
        }
    }
    
    private var resultSection: some View {
        VStack(spacing: 16) {
            Text("Result")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Converted Amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    Text(formatConvertedAmount())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(toCurrency.symbol)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    Text("Exchange Rate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("1 \(fromCurrency.rawValue) = \(String(format: "%.4f", exchangeRate)) \(toCurrency.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Last Updated")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(lastUpdated, style: .time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
    }
    
    private func convertCurrency() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            convertedAmount = 0
            return
        }
        
        // Simulated exchange rates (in real app, you'd use a real API)
        let rates: [Currency: [Currency: Double]] = [
            .usd: [.eur: 0.85, .gbp: 0.73, .jpy: 110.0, .cad: 1.25, .aud: 1.35, .chf: 0.92, .cny: 6.45, .rub: 75.0, .krw: 1150.0],
            .eur: [.usd: 1.18, .gbp: 0.86, .jpy: 129.0, .cad: 1.47, .aud: 1.59, .chf: 1.08, .cny: 7.59, .rub: 88.0, .krw: 1350.0],
            .gbp: [.usd: 1.37, .eur: 1.16, .jpy: 150.0, .cad: 1.71, .aud: 1.85, .chf: 1.26, .cny: 8.84, .rub: 102.0, .krw: 1570.0],
            .jpy: [.usd: 0.0091, .eur: 0.0077, .gbp: 0.0067, .cad: 0.011, .aud: 0.012, .chf: 0.0084, .cny: 0.059, .rub: 0.68, .krw: 10.5],
            .cad: [.usd: 0.80, .eur: 0.68, .gbp: 0.58, .jpy: 88.0, .aud: 1.08, .chf: 0.74, .cny: 5.16, .rub: 60.0, .krw: 920.0],
            .aud: [.usd: 0.74, .eur: 0.63, .gbp: 0.54, .jpy: 81.5, .cad: 0.93, .chf: 0.68, .cny: 4.78, .rub: 55.5, .krw: 852.0],
            .chf: [.usd: 1.09, .eur: 0.93, .gbp: 0.79, .jpy: 119.0, .cad: 1.35, .aud: 1.47, .cny: 7.01, .rub: 81.5, .krw: 1250.0],
            .cny: [.usd: 0.155, .eur: 0.132, .gbp: 0.113, .jpy: 17.0, .cad: 0.194, .aud: 0.209, .chf: 0.143, .rub: 11.6, .krw: 178.0],
            .rub: [.usd: 0.0133, .eur: 0.0114, .gbp: 0.0098, .jpy: 1.47, .cad: 0.0167, .aud: 0.018, .chf: 0.0123, .cny: 0.086, .krw: 15.3],
            .krw: [.usd: 0.00087, .eur: 0.00074, .gbp: 0.00064, .jpy: 0.095, .cad: 0.00109, .aud: 0.00117, .chf: 0.0008, .cny: 0.0056, .rub: 0.065]
        ]
        
        if fromCurrency == toCurrency {
            exchangeRate = 1.0
            convertedAmount = amountValue
        } else {
            exchangeRate = rates[fromCurrency]?[toCurrency] ?? 1.0
            convertedAmount = amountValue * exchangeRate
        }
        
        lastUpdated = Date()
    }
    
    private func formatConvertedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: convertedAmount)) ?? "0.00"
    }
}

struct CurrencyPicker: View {
    let title: String
    @Binding var selectedCurrency: CurrencyConverterView.Currency
    let isFrom: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(isFrom ? .blue : .green)
            
            Menu {
                ForEach(CurrencyConverterView.Currency.allCases, id: \.self) { currency in
                    Button(action: {
                        selectedCurrency = currency
                    }) {
                        HStack {
                            Text(currency.symbol)
                            Text(currency.rawValue)
                            Text("-")
                            Text(currency.name)
                            if selectedCurrency == currency {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedCurrency.symbol)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(selectedCurrency.rawValue)
                            .font(.headline)
                        Text(selectedCurrency.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
}

#Preview {
    CurrencyConverterView()
} 