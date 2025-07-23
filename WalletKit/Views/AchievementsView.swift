import SwiftUI

struct AchievementsView: View {
    @StateObject private var achievementManager = AchievementManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Level: \(achievementManager.userStats.level)")
                            .font(.title2)
                        Text("Points: \(achievementManager.userStats.points)")
                            .font(.subheadline)
                    }
                    Spacer()
                }
                ProgressView(value: Double(achievementManager.userStats.points % 100) / 100.0)
                    .accentColor(.orange)
                    .padding(.bottom)
                List {
                    ForEach(achievementManager.userStats.achievements) { achievement in
                        HStack {
                            Image(systemName: achievement.icon)
                                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
                            VStack(alignment: .leading) {
                                Text(achievement.title)
                                    .font(.headline)
                                Text(achievement.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            if achievement.isUnlocked {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Achievements")
        }
    }
} 