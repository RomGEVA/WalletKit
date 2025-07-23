import Foundation
import SwiftUI

@MainActor
class AchievementManager: ObservableObject {
    @Published var userStats: UserStats = UserStats(points: 0, level: 1, achievements: [])
    private let userDefaults = UserDefaults.standard
    private let statsKey = "userStats_v1"
    
    // Predefined achievements
    static let defaultAchievements: [Achievement] = [
        Achievement(title: "First Goal", description: "Create your first financial goal.", icon: "flag.fill"),
        Achievement(title: "Goal Achiever", description: "Complete a goal.", icon: "checkmark.seal.fill"),
        Achievement(title: "Persistent Planner", description: "Add 5 goals.", icon: "calendar"),
        Achievement(title: "Big Dreamer", description: "Create a goal with a target amount over 10,000.", icon: "star.fill"),
        Achievement(title: "Quick Start", description: "Complete a goal within a week.", icon: "bolt.fill"),
        Achievement(title: "Category Master", description: "Create goals in 3 different categories.", icon: "folder.fill"),
        Achievement(title: "Streak Starter", description: "Complete goals 3 days in a row.", icon: "flame.fill"),
        Achievement(title: "Long-Term Vision", description: "Set a goal with a deadline over a year.", icon: "clock.fill"),
        Achievement(title: "Goal Collector", description: "Have 10 active goals at once.", icon: "tray.full.fill"),
        Achievement(title: "Finisher", description: "Complete 10 goals.", icon: "rosette"),
    ]
    
    init() {
        loadStats()
        ensureDefaultAchievements()
    }
    
    // MARK: - Data Persistence
    private func loadStats() {
        if let data = userDefaults.data(forKey: statsKey) {
            if let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
                userStats = decoded
                return
            }
        }
        userStats = UserStats(points: 0, level: 1, achievements: [])
    }
    
    private func saveStats() {
        if let encoded = try? JSONEncoder().encode(userStats) {
            userDefaults.set(encoded, forKey: statsKey)
        }
    }
    
    // Ensure default achievements are present
    private func ensureDefaultAchievements() {
        for achievement in Self.defaultAchievements {
            if !userStats.achievements.contains(where: { $0.title == achievement.title }) {
                userStats.achievements.append(achievement)
            }
        }
        saveStats()
    }
    
    // MARK: - Points & Level
    func addPoints(_ points: Int) {
        userStats.points += points
        updateLevel()
        saveStats()
    }
    
    private func updateLevel() {
        let newLevel = 1 + userStats.points / 100
        if newLevel > userStats.level {
            userStats.level = newLevel
        }
    }
    
    // MARK: - Achievements
    func unlockAchievement(_ achievement: Achievement) {
        if let index = userStats.achievements.firstIndex(where: { $0.id == achievement.id }) {
            if !userStats.achievements[index].isUnlocked {
                userStats.achievements[index].isUnlocked = true
                userStats.achievements[index].dateUnlocked = Date()
                addPoints(50) // +50 points for unlocking an achievement
            }
        } else {
            var unlocked = achievement
            unlocked.isUnlocked = true
            unlocked.dateUnlocked = Date()
            userStats.achievements.append(unlocked)
            addPoints(50) // +50 points for unlocking an achievement
        }
        saveStats()
    }
    
    func addAchievement(_ achievement: Achievement) {
        if !userStats.achievements.contains(where: { $0.id == achievement.id }) {
            userStats.achievements.append(achievement)
            saveStats()
        }
    }
    
    func resetAchievements() {
        userStats.achievements = []
        saveStats()
    }
    
    func resetAllStats() {
        userStats = UserStats(points: 0, level: 1, achievements: [])
        saveStats()
    }
}

extension AchievementManager {
    func unlockAchievementByTitle(_ title: String) {
        if let achievement = userStats.achievements.first(where: { $0.title == title }) {
            unlockAchievement(achievement)
        }
    }
} 