import Foundation
import SwiftUI

@MainActor
class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    private let userDefaults = UserDefaults.standard
    private let goalsKey = "goals_v1"
    private let achievementManager: AchievementManager
    
    init(achievementManager: AchievementManager) {
        self.achievementManager = achievementManager
        loadGoals()
    }
    
    // MARK: - Data Persistence
    private func loadGoals() {
        if let data = userDefaults.data(forKey: goalsKey) {
            if let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
                goals = decoded
                return
            }
        }
        goals = []
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            userDefaults.set(encoded, forKey: goalsKey)
        }
    }
    
    // MARK: - Goal Management
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
        // Unlock 'First Goal'
        if goals.count == 1 {
            achievementManager.unlockAchievementByTitle("First Goal")
        }
        // Unlock 'Persistent Planner'
        if goals.count >= 5 {
            achievementManager.unlockAchievementByTitle("Persistent Planner")
        }
        // Unlock 'Big Dreamer'
        if goal.targetAmount > 10_000 {
            achievementManager.unlockAchievementByTitle("Big Dreamer")
        }
        // Unlock 'Category Master'
        let uniqueCategories = Set(goals.map { $0.category })
        if uniqueCategories.count >= 3 {
            achievementManager.unlockAchievementByTitle("Category Master")
        }
        // Unlock 'Goal Collector'
        if goals.count >= 10 {
            achievementManager.unlockAchievementByTitle("Goal Collector")
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            let wasCompleted = goals[index].isCompleted
            goals[index] = goal
            saveGoals()
            // Unlock 'Goal Achiever' and 'Finisher' when goal is completed
            if !wasCompleted && goal.isCompleted {
                achievementManager.unlockAchievementByTitle("Goal Achiever")
                let completedCount = goals.filter { $0.isCompleted }.count
                if completedCount >= 10 {
                    achievementManager.unlockAchievementByTitle("Finisher")
                }
            }
        }
    }
    
    func addAmountToGoal(_ goal: Goal, amount: Double, note: String? = nil) {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        goals[index].currentAmount += amount
        let transaction = GoalTransaction(amount: amount, date: Date(), note: note)
        goals[index].history.append(transaction)
        if goals[index].currentAmount >= goals[index].targetAmount {
            goals[index].isCompleted = true
        }
        saveGoals()
    }
    
    func getHistory(for goal: Goal) -> [GoalTransaction] {
        return goals.first(where: { $0.id == goal.id })?.history ?? []
    }
    
    func resetAllGoals() {
        goals = []
        saveGoals()
    }
} 