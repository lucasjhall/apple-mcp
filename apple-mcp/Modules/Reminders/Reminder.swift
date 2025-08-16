//
//  Reminder.swift
//  apple-mcp
//

import Foundation

struct Reminder: Identifiable {
    var id: String // This will be the EKReminder's calendarItemIdentifier
    var title: String
    var isCompleted: Bool
    var dueDate: Date?
}
