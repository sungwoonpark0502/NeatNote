import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var taskDescription: String = ""
    @State private var dueDate: Date = Date()
    @State private var priority: String = "Medium"
    @State private var category: String = "Work" // Default to one of the predefined categories

    private let categories = ["Work", "School", "Exercise", "Personal", "Other"] // List of categories
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 15) {
                Form {
                    Section(header: Text("New Task Details")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $taskDescription)
                        DatePicker("Date & Time", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                        Picker("Priority", selection: $priority) {
                            ForEach(["Low", "Medium", "High"], id: \.self) {
                                Text($0)
                            }
                        }
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) {
                                Text($0)
                            }
                        }
                        // Removed custom category input
                    }
                }
                .navigationBarTitle("Add Task", displayMode: .inline)
                .navigationBarItems(
                    leading: Button(action: {
                        presentationMode.wrappedValue.dismiss() // Cancel action
                    }) {
                        Text("Cancel")
                    },
                    trailing: Button(action: {
                        saveTask()
                    }) {
                        Text("Save")
                    }
                    .disabled(title.isEmpty) // Disable Save button if title is empty
                )
            }
        }
    }
    
    private func saveTask() {
        let newTask = TaskEntity(context: viewContext)
        newTask.title = title
        newTask.taskDescription = taskDescription
        newTask.dueDate = dueDate
        newTask.priority = priority
        newTask.category = category // Set to the selected category
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
