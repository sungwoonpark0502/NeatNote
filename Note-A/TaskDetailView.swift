import SwiftUI

struct TaskDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isEditing = false
    @State private var categories: [String] = ["Work", "School", "Exercise", "Personal", "Other"]
    
    // State variables for editing
    @State private var title: String
    @State private var taskDescription: String
    @State private var dueDate: Date
    @State private var priority: String
    @State private var category: String
    
    var task: TaskEntity
    
    init(task: TaskEntity) {
        self.task = task
        _title = State(initialValue: task.title ?? "")
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _priority = State(initialValue: task.priority ?? "Medium")
        _category = State(initialValue: task.category ?? "Work")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            if isEditing {
                TaskEditView(task: task)
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    Text(task.title ?? "No Title")
                        .font(.title)
                    Text("\(task.dueDate ?? Date(), style: .date) \(task.dueDate ?? Date(), style: .time)")
                        .font(.body)
                    Text(task.taskDescription ?? "No Description")
                        .font(.body)
                    HStack {
                        PriorityIndicator(priority: task.priority ?? "Medium")
                            .padding(.trailing, 5)
                        Text("Priority: \(task.priority ?? "Medium")")
                            .font(.body)
                    }
                    Text("Category: \(task.category ?? "Work")")
                        .font(.body)
                }
                .padding(.leading, 0) // Left padding
                .padding(.top, 30) // Top padding
            }
            
            Spacer() // Pushes content to the top
        }
        .navigationBarTitle(isEditing ? "Edit Task" : "Task Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
        }) {
            Text(isEditing ? "" : "Edit")
        })
        .padding(.top, 10) // Adjust top padding for overall view
        .onAppear(perform: loadCategories)
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: "customCategories") as? [String] {
            categories = savedCategories
        }
    }
}
