import SwiftUI

struct GoalsView: View {
    @StateObject private var achievementManager = AchievementManager()
    @StateObject private var goalManager: GoalManager
    @State private var showingAddGoal = false
    
    init() {
        let achievementManager = AchievementManager()
        _achievementManager = StateObject(wrappedValue: achievementManager)
        _goalManager = StateObject(wrappedValue: GoalManager(achievementManager: achievementManager))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(goalManager.goals) { goal in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(goal.title)
                                .font(.headline)
                            Spacer()
                            Text("\(Int(goal.currentAmount))/\(Int(goal.targetAmount))")
                                .font(.subheadline)
                        }
                        ProgressView(value: min(goal.currentAmount / goal.targetAmount, 1.0))
                            .accentColor(.blue)
                        if let deadline = goal.deadline {
                            Text("Due: \(deadline, formatter: dateFormatter)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if goal.isCompleted {
                            Text("Goal completed!")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Button("Mark as Completed") {
                                var updatedGoal = goal
                                updatedGoal.isCompleted = true
                                goalManager.updateGoal(updatedGoal)
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    indexSet.forEach { goalManager.deleteGoal(goalManager.goals[$0]) }
                }
            }
            .navigationTitle("My Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddGoal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goalManager: goalManager)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()

struct AddGoalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var goalManager: GoalManager
    @State private var title = ""
    @State private var targetAmount = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var category = "General"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("e.g. Vacation", text: $title)
                }
                Section(header: Text("Target Amount")) {
                    TextField("0", text: $targetAmount)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("Category")) {
                    TextField("Category", text: $category)
                }
                Section(header: Text("Deadline")) {
                    Toggle("Set deadline", isOn: $hasDeadline)
                    if hasDeadline {
                        DatePicker("", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("New Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Double(targetAmount), !title.isEmpty {
                            let goal = Goal(title: title, targetAmount: amount, deadline: hasDeadline ? deadline : nil, category: category)
                            goalManager.addGoal(goal)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
} 