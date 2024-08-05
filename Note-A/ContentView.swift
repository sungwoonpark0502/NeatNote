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
    @State private var showingDeleteConfirmation = false // For delete confirmation dialog
    @State private var showingDeleteAlert = false // For custom alert dialog
    @State private var showingSettingsView = false // For navigating to SettingsView
    
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
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding([.leading, .trailing, .top])
                
                // Category selection button
                HStack {
                    Spacer()
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
                .padding(.bottom, 5) // Reduce bottom padding
                
                List {
                    ForEach(filteredTasks, id: \.self) { task in
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            TaskRow(task: task)
                        }
                    }
                    .onDelete(perform: deleteTasks)
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
                    .confirmationDialog(
                        "Are you sure you want to delete all tasks?",
                        isPresented: $showingDeleteConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Delete All", role: .destructive) {
                            deleteAllTasks()
                        }
                        Button("Cancel", role: .cancel) { }
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
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Delete All Tasks"),
                        message: Text("Are you sure you want to delete all tasks?"),
                        primaryButton: .destructive(Text("Delete All")) {
                            deleteAllTasks()
                        },
                        secondaryButton: .cancel()
                    )
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
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
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
