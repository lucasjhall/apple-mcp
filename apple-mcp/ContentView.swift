//
//  ContentView.swift
//  apple-mcp
//
//  Created by lucas on 8/16/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    // Server state
    @State private var isServerRunning = false
    @State private var serverStatusMessage = "Server Status: Not started"
    private let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()
    private let networkingManager = NetworkingManager.shared

    // Reminders state
    @State private var reminders: [Reminder] = []
    private let remindersManager = RemindersManager.shared

    var body: some View {
        VStack(spacing: 20) {
            WelcomeView()
            Divider()
            serverStatusSection
            Divider()
            remindersSection
        }
        .padding()
        .onAppear {
            checkServerStatus()
            loadReminders()
        }
        .onReceive(timer) { _ in
            checkServerStatus()
        }
    }

    // Server Status UI
    private var serverStatusSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HTTP Server Information")
                .font(.headline)
            Text(serverStatusMessage)
                .font(.subheadline)
                .foregroundColor(isServerRunning ? .green : .red)
            Text("Endpoint: \(networkingManager.healthCheckEndpointString)")
                .font(.system(.body, design: .monospaced))
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }

    // Reminders UI
    private var remindersSection: some View {
        VStack(alignment: .leading) {
            Text("Reminders")
                .font(.headline)
            HStack {
                Button("Add Reminder") {
                    createTestReminder()
                }
                Spacer()
                Button("Refresh") {
                    loadReminders()
                }
            }
            List {
                ForEach(reminders) { reminder in
                    HStack {
                        Button(action: {
                            toggleCompletion(for: reminder)
                        }) {
                            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                        }
                        .buttonStyle(BorderlessButtonStyle())

                        Text(reminder.title)
                    }
                }
                .onDelete(perform: deleteReminder)
            }
        }
        .padding()
    }

    // --- Helper Methods ---

    private func checkServerStatus() {
        guard let url = networkingManager.healthCheckURL else { return }
        URLSession.shared.dataTask(with: url) { _, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.isServerRunning = true
                    self.serverStatusMessage = "Server Status: Running ✓"
                } else {
                    self.isServerRunning = false
                    self.serverStatusMessage = "Server Status: Not responding"
                }
            }
        }.resume()
    }

    private func loadReminders() {
        remindersManager.getReminders { (reminders, error) in
            if let reminders = reminders {
                DispatchQueue.main.async {
                    self.reminders = reminders
                }
            }
        }
    }

    private func createTestReminder() {
        let title = "Test Reminder \(Int.random(in: 1...100))"
        remindersManager.createReminder(title: title, dueDate: nil) { error in
            if error == nil {
                loadReminders()
            }
        }
    }

    private func toggleCompletion(for reminder: Reminder) {
        var updatedReminder = reminder
        updatedReminder.isCompleted.toggle()
        remindersManager.updateReminder(updatedReminder) { error in
            if error == nil {
                loadReminders()
            }
        }
    }

    private func deleteReminder(at offsets: IndexSet) {
        let remindersToDelete = offsets.map { reminders[$0] }
        for reminder in remindersToDelete {
            remindersManager.deleteReminder(reminder) { error in
                if error == nil {
                    loadReminders()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
