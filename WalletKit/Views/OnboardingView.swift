import SwiftUI

// MARK: - Onboarding View
struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        TabView {
            OnboardingPageView(
                imageName: "dollarsign.circle.fill",
                title: "Welcome to Wallest",
                description: "The simplest way to track your income and expenses, helping you achieve your financial goals."
            )
            
            OnboardingPageView(
                imageName: "plus.circle.fill",
                title: "Add Transactions Easily",
                description: "Quickly add new transactions for income or expenses with just a few taps."
            )
            
            OnboardingPageView(
                imageName: "target",
                title: "Set & Track Budgets",
                description: "Create custom budgets for different categories to keep your spending in check."
            )
            
            OnboardingPageView(
                imageName: "chart.pie.fill",
                title: "Visualize Your Spending",
                description: "Get a clear view of your financial health with insightful charts and analytics.",
                showsDismissButton: true,
                onDismiss: {
                    hasCompletedOnboarding = true
                }
            )
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    var showsDismissButton = false
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: imageName)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.mint)
            
            VStack(spacing: 16) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if showsDismissButton {
                Button(action: {
                    onDismiss?()
                }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.mint)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

// MARK: - Preview
#if DEBUG
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
#endif 