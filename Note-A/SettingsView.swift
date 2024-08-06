import SwiftUI
import UserNotifications
import CoreData

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false // Dark mode preference
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TaskEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)],
        predicate: NSPredicate(format: "dueDate >= %@", Date() as NSDate)
    ) private var tasks: FetchedResults<TaskEntity>

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Dark Mode Toggle
            Toggle("Dark Mode", isOn: $darkModeEnabled)
                .padding()
                .onChange(of: darkModeEnabled) { _ in
                    applyAppearance()
                }

            // Notifications Toggle
            Toggle("Notifications", isOn: $notificationsEnabled)
                .onChange(of: notificationsEnabled) { value in
                    if value {
                        requestNotificationPermissions()
                    } else {
                        removeAllPendingNotifications()
                    }
                }
                .padding()

            // Explanation Text for Notifications
            Text("Enable notifications 1 day and 1 hour before the due date and time. (Currently Not Working)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding([.leading, .trailing])

            Spacer()
            
            // Version text at the bottom
            Text("Version 1.0")
                .font(.footnote) // Small font size
                .foregroundColor(.gray) // Optional: Set text color to gray
                .padding(.bottom, 5) // Space from the bottom
                .frame(maxWidth: .infinity, alignment: .center) // Centered text
            
            // Designer text
            Text("Designed by Sungwoon Park")
                .font(.footnote) // Small font size
                .foregroundColor(.gray) // Optional: Set text color to gray
                .padding(.bottom, 10) // Space from the bottom
                .frame(maxWidth: .infinity, alignment: .center) // Centered text
        }
        .navigationTitle("Settings")
        .padding()
        .onAppear {
            applyAppearance() // Ensure the correct appearance is applied when the view appears
        }
    }

    private func applyAppearance() {
        // Apply dark or light mode based on the user preference
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle = darkModeEnabled ? .dark : .light
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                scheduleNotifications()
            } else {
                DispatchQueue.main.async {
                    notificationsEnabled = false
                }
            }
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    private func scheduleNotifications() {
        // Schedule notifications for each task
        for task in tasks {
            guard let dueDate = task.dueDate else { continue }
            let content = UNMutableNotificationContent()
            content.title = "Task Reminder"
            content.body = "You have a task due soon."

            let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: dueDate)!
            let oneHourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate)!

            let trigger1 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneDayBefore), repeats: false)
            let trigger2 = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneHourBefore), repeats: false)

            let request1 = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger1)
            let request2 = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger2)

            UNUserNotificationCenter.current().add(request1) { error in
                if let error = error {
                    print("Error adding notification: \(error.localizedDescription)")
                }
            }
            UNUserNotificationCenter.current().add(request2) { error in
                if let error = error {
                    print("Error adding notification: \(error.localizedDescription)")
                }
            }
        }
    }

    private func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
