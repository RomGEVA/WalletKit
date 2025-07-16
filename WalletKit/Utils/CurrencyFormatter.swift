

import Foundation

class CurrencyFormatter {
    static let shared = CurrencyFormatter()
    
    private let formatter: NumberFormatter
    
    private init() {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
    }
    
    func format(_ amount: Double) -> String {
        return formatter.string(from: NSNumber(value: amount)) ?? "$0.00"
    }
} 
