//
//  Note_AApp.swift
//  Note-A
//
//  Created by James Park on 8/5/24.
//

import SwiftUI

@main
struct Note_AApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
