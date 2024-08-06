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
                        .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "calendar")
                        Text("\(task.dueDate ?? Date(), style: .date) \(task.dueDate ?? Date(), style: .time)")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    Text(task.taskDescription?.isEmpty == false ? task.taskDescription! : "No Description")
                        .font(.body)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "exclamationmark.circle")
                        Text(task.priority ?? "Medium")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "tag")
                        Text(task.category ?? "Work")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .navigationBarTitle(isEditing ? "Edit Task" : "Task Details", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isEditing.toggle()
        }) {
            Text(isEditing ? "" : "Edit")
        })
        .padding(.top, 10)
        .onAppear(perform: loadCategories)
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.array(forKey: "customCategories") as? [String] {
            categories = savedCategories
        }
    }
}
