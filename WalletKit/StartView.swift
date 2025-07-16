//
//  StartView.swift
//  WalletKit
//
//  Created by Роман Главацкий on 16.07.2025.
//

import SwiftUI

struct StartView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var financeManager = FinanceManager()
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
                .environmentObject(financeManager)
        } else {
            OnboardingView()
        }
    }
}

#Preview {
    StartView()
}
