//
//  ContentView.swift


import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "chart.pie.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Transactions")
                }
                .tag(1)
            
            BudgetView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Budget")
                }
                .tag(2)
            
            AnalyticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.mint)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
