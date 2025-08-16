//
//  RemindersManager.swift
//  apple-mcp
//

import Foundation
import EventKit

class RemindersManager {
    static let shared = RemindersManager()
    private let eventStore = EKEventStore()

    private var hasAccess: Bool = false

    private init() {
        requestAccess { (granted, error) in
            if granted {
                self.hasAccess = true
            }
        }
    }

    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .reminder) { (granted, error) in
            completion(granted, error)
        }
    }

    func getReminders(completion: @escaping ([Reminder]?, Error?) -> Void) {
        guard hasAccess else {
            completion(nil, RemindersError.accessDenied)
            return
        }

        let predicate = eventStore.predicateForReminders(in: nil)
        eventStore.fetchReminders(matching: predicate) { (ekReminders) in
            let reminders = ekReminders?.map { ekReminder in
                return Reminder(
                    id: ekReminder.calendarItemIdentifier,
                    title: ekReminder.title,
                    isCompleted: ekReminder.isCompleted,
                    dueDate: ekReminder.dueDateComponents?.date
                )
            }
            completion(reminders, nil)
        }
    }

    func createReminder(title: String, dueDate: Date?, completion: @escaping (Error?) -> Void) {
        guard hasAccess else {
            completion(RemindersError.accessDenied)
            return
        }

        let newReminder = EKReminder(eventStore: eventStore)
        newReminder.title = title
        if let dueDate = dueDate {
            newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        }
        newReminder.calendar = eventStore.defaultCalendarForNewReminders()

        do {
            try eventStore.save(newReminder, commit: true)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func updateReminder(_ reminder: Reminder, completion: @escaping (Error?) -> Void) {
        guard hasAccess else {
            completion(RemindersError.accessDenied)
            return
        }

        guard let ekReminder = eventStore.calendarItem(withIdentifier: reminder.id) as? EKReminder else {
            completion(RemindersError.notFound)
            return
        }

        ekReminder.title = reminder.title
        ekReminder.isCompleted = reminder.isCompleted
        if let dueDate = reminder.dueDate {
            ekReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        } else {
            ekReminder.dueDateComponents = nil
        }

        do {
            try eventStore.save(ekReminder, commit: true)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteReminder(_ reminder: Reminder, completion: @escaping (Error?) -> Void) {
        guard hasAccess else {
            completion(RemindersError.accessDenied)
            return
        }

        guard let ekReminder = eventStore.calendarItem(withIdentifier: reminder.id) as? EKReminder else {
            completion(RemindersError.notFound)
            return
        }

        do {
            try eventStore.remove(ekReminder, commit: true)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

enum RemindersError: Error {
    case accessDenied
    case notFound
}
