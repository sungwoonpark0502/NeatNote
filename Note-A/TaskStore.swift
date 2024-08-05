import Foundation
import CoreData
import Combine

class TaskStore: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    
    private var viewContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        fetchTasks()
    }
    
    func fetchTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            tasks = try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
        }
    }
    
    func save(task: TaskEntity) {
        do {
            try viewContext.save()
            fetchTasks()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    func delete(task: TaskEntity) {
        viewContext.delete(task)
        do {
            try viewContext.save()
            fetchTasks()
        } catch {
            print("Error deleting task: \(error)")
        }
    }
}
