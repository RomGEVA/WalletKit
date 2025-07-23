//

import SwiftUI
import StoreKit
import SafariServices

struct SettingsView: View {
    @EnvironmentObject var financeManager: FinanceManager
    @Environment(\.requestReview) var requestReview
    
    @State private var showingResetAlert = false
    @State private var showingSafari = false
    
    private let privacyPolicyURL = "https://wallest.app/privacy"
    
    var body: some View {
        NavigationView {
            List {
                // App Information
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Wallest")
                                .font(.headline)
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                
                // Data Management
                Section("Data Management") {
                    Button(action: { showingResetAlert = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Reset All Data")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                // Statistics
                Section("Statistics") {
                    StatRow(
                        icon: "list.bullet",
                        title: "Total Transactions",
                        value: "\(financeManager.transactions.count)",
                        color: .blue
                    )
                    
                    StatRow(
                        icon: "target",
                        title: "Active Budgets",
                        value: "\(financeManager.budgets.count)",
                        color: .green
                    )
                    
                    StatRow(
                        icon: "tag.fill",
                        title: "Categories",
                        value: "\(financeManager.categories.count)",
                        color: .purple
                    )
                    
                    StatRow(
                        icon: "calendar",
                        title: "Days Active",
                        value: "\(calculateDaysActive())",
                        color: .orange
                    )
                }
                
                // Support & Feedback
                Section("Support & Feedback") {
                    Button(action: { showingSafari = true }) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Privacy Policy")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { requestReview() }) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            Text("Rate App")
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                financeManager.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your transactions, budgets, and categories. This action cannot be undone.")
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: privacyPolicyURL)!)
        }
    }
    
    private func calculateDaysActive() -> Int {
        guard let firstTransaction = financeManager.transactions.min(by: { $0.date < $1.date }) else {
            return 1
        }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: firstTransaction.date, to: Date()).day ?? 1
        return max(days, 1)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(FinanceManager())
} 
