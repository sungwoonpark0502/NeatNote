import SwiftUI

@main
struct Note_AApp: App {
    let persistenceController = PersistenceController.shared
    
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @StateObject private var taskStore: TaskStore
    
    init() {
        let context = persistenceController.container.viewContext
        _taskStore = StateObject(wrappedValue: TaskStore(viewContext: context))
    }

    @State private var isLoading = true // Track loading state
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                LoadingView()
                    .onAppear {
                        // Simulate loading time
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            isLoading = false
                        }
                    }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(taskStore)
                    .preferredColorScheme(darkModeEnabled ? .dark : .light)
            }
        }
    }
}
