import SwiftUI
import CoreData

@main
struct Note_AApp: App {
    let persistenceController = PersistenceController.shared
    
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
                .preferredColorScheme(darkModeEnabled ? .dark : .light) // Apply dark mode setting
        }
    }
}
