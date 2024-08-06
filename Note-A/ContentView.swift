import SwiftUI
import CoreData
import UserNotifications

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TaskEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<TaskEntity>
    
    @State private var showingAddTaskView = false
    @State private var searchText = ""
    @State private var selectedCategory: String = "All" // Default to "All"
    @State private var showingDeleteAlert = false // For custom alert dialog
    @State private var showingSettingsView = false // For navigating to SettingsView
    @State private var isSelecting = false // Toggle for selection mode
    @State private var selectedTaskIDs = Set<NSManagedObjectID>() // Store selected task IDs
    
    private let categories: [String] = ["All", "Work", "School", "Exercise", "Personal", "Other"]
    
    var filteredTasks: [TaskEntity] {
        tasks.filter { task in
            let matchesSearch = searchText.isEmpty || (task.title ?? "").localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == "All" || task.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                HStack {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .top])
                    
                    Spacer()
                }
                
                // Select and Category buttons
                HStack {
                    if isSelecting {
                        Button(action: {
                            isSelecting.toggle()
                            selectedTaskIDs.removeAll() // Clear selection when exiting selection mode
                        }) {
                            Text("Cancel")
                                .padding(5)
                        }
                        .padding(.leading)
                    } else {
                        Button(action: {
                            isSelecting.toggle()
                        }) {
                            Text("Select")
                                .padding(5)
                        }
                        .padding(.leading)
                    }
                    
                    Spacer()
                    
                    // Only show Category button if not in selection mode
                    if !isSelecting {
                        Menu {
                            ForEach(categories, id: \.self) { category in
                                Button(category) {
                                    selectedCategory = category
                                }
                            }
                        } label: {
                            Text("Category: \(selectedCategory)")
                                .font(.subheadline) // Smaller font size
                                .padding(5) // Small padding around text
                        }
                        .padding(.trailing) // Adjust right padding as needed
                    }
                    
                    // Show Delete Selected button only when selecting and tasks are selected
                    if isSelecting && !selectedTaskIDs.isEmpty {
                        Button(action: {
                            deleteSelectedTasks() // Directly delete selected tasks
                        }) {
                            Text("Delete Selected")
                                .foregroundColor(.red)
                                .padding(5)
                        }
                        .padding(.trailing)
                    }
                }
                .padding(.bottom, 5) // Reduce bottom padding
                
                if filteredTasks.isEmpty {
                    Spacer()
                    Text("No Tasks")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks, id: \.objectID) { task in
                            HStack {
                                if isSelecting {
                                    Button(action: {
                                        let taskID = task.objectID
                                        if selectedTaskIDs.contains(taskID) {
                                            selectedTaskIDs.remove(taskID)
                                        } else {
                                            selectedTaskIDs.insert(taskID)
                                        }
                                    }) {
                                        Image(systemName: selectedTaskIDs.contains(task.objectID) ? "checkmark.circle.fill" : "circle")
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Prevent default button styling
                                }
                                
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskRow(task: task)
                                }
                                .opacity(isSelecting ? 0.5 : 1) // Dim the row when selecting
                                .disabled(isSelecting) // Disable interaction when selecting
                            }
                        }
                        .onDelete(perform: deleteTasks)
                    }
                }
            }
            .navigationBarTitle(Text("Note-A").font(.system(size: 20)), displayMode: .inline)
            .navigationBarItems(
                leading: Menu {
                    Button(action: {
                        showingDeleteAlert.toggle() // Show custom alert
                    }) {
                        Text("Delete All")
                            .foregroundColor(.red) // Set color to red
                    }
                    
                    Button(action: {
                        showingSettingsView = true // Trigger navigation to SettingsView
                    }) {
                        Text("Settings")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle") // Button with three dots
                }
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete All Tasks"),
                        message: Text("Are you sure you want to delete all tasks?"),
                        primaryButton: .destructive(Text("Delete All")) {
                            deleteAllTasks()
                        },
                        secondaryButton: .cancel()
                    )
                },
                trailing: Button(action: {
                    showingAddTaskView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView().environment(\.managedObjectContext, viewContext)
            }
            .background(
                NavigationLink(
                    destination: SettingsView(),
                    isActive: $showingSettingsView,
                    label: { EmptyView() }
                )
            )
            
            // Version text at the bottom
            Text("Version 1.0")
                .font(.footnote) // Small font size
                .foregroundColor(.gray) // Optional: Set text color to gray
                .padding(.bottom, 10) // Space from the bottom
                .frame(maxWidth: .infinity, alignment: .center) // Centered text
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredTasks[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteAllTasks() {
        withAnimation {
            tasks.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func deleteSelectedTasks() {
        withAnimation {
            selectedTaskIDs.forEach { taskID in
                if let task = viewContext.object(with: taskID) as? TaskEntity {
                    viewContext.delete(task)
                }
            }
            do {
                try viewContext.save()
                selectedTaskIDs.removeAll()
                isSelecting = false // Exit selection mode after deletion
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TaskRow: View {
    var task: TaskEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title ?? "No Title")
                    .font(.headline)
                Text("\(task.dueDate ?? Date(), style: .date) \(task.dueDate ?? Date(), style: .time)")
                    .font(.subheadline)
            }
            Spacer()
            PriorityIndicator(priority: task.priority ?? "Medium")
        }
    }
}

struct PriorityIndicator: View {
    var priority: String
    
    var body: some View {
        Circle()
            .fill(priorityColor(priority))
            .frame(width: 10, height: 10) // Small dot size
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "Low":
            return .green
        case "Medium":
            return .yellow
        case "High":
            return .red
        default:
            return .gray
        }
    }
}
