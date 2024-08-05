import SwiftUI

struct TaskEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var taskDescription: String
    @State private var dueDate: Date
    @State private var priority: String
    @State private var category: String
    @State private var hasChanges = false // Track if any changes are made
    
    private let categories = ["Work", "School", "Exercise", "Personal", "Other"] // List of categories
    
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
            Form {
                Section(header: Text("Edit Task Details")) {
                    TextField("Title", text: $title)
                        .onChange(of: title) { _ in hasChanges = true }
                    TextField("Description", text: $taskDescription)
                        .onChange(of: taskDescription) { _ in hasChanges = true }
                    DatePicker("Date & Time", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        .onChange(of: dueDate) { _ in hasChanges = true }
                    Picker("Priority", selection: $priority) {
                        ForEach(["Low", "Medium", "High"], id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: priority) { _ in hasChanges = true }
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) {
                            Text($0)
                        }
                    }
                    .onChange(of: category) { _ in hasChanges = true }
                }
                
                Button("Delete") {
                    deleteTask()
                }
                .foregroundColor(.red)
            }
            
            Spacer()
        }
        .navigationBarTitle("Edit Task", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                if hasChanges {
                    saveChanges()
                } else {
                    presentationMode.wrappedValue.dismiss() // No changes, just dismiss
                }
            }) {
                Text("Save")
            }
            .disabled(!hasChanges) // Disable Save button if no changes were made
        )
        .padding(.top, 10) // Adjust top padding for overall view
    }
    
    private func saveChanges() {
        task.title = title
        task.taskDescription = taskDescription
        task.dueDate = dueDate
        task.priority = priority
        task.category = category // Always use selected category
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Go back to the TaskDetailView
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteTask() {
        viewContext.delete(task)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss() // Go back to the TaskDetailView
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
