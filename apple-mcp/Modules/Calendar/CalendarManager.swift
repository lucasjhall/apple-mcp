import Foundation
import EventKit

class CalendarManager {
    private let eventStoreManager: EventStoreManager

    init(eventStoreManager: EventStoreManager = .shared) {
        self.eventStoreManager = eventStoreManager
    }

    func getEvents(from startDate: Date, to endDate: Date, completion: @escaping ([EKEvent]?, Error?) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            completion(nil, NSError(domain: "CalendarManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access to calendar is denied."]))
            return
        }

        if startDate > endDate {
            completion(nil, NSError(domain: "CalendarManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Start date cannot be after end date."]))
            return
        }

        let predicate = eventStoreManager.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStoreManager.eventStore.events(matching: predicate)
        completion(events, nil)
    }

    func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            completion(NSError(domain: "CalendarManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access to calendar is denied."]))
            return
        }

        let event = EKEvent(eventStore: eventStoreManager.eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStoreManager.eventStore.defaultCalendarForNewEvents

        do {
            try eventStoreManager.eventStore.save(event, span: .thisEvent)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func updateEvent(identifier: String, title: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            completion(NSError(domain: "CalendarManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access to calendar is denied."]))
            return
        }

        guard let event = eventStoreManager.eventStore.event(withIdentifier: identifier) else {
            completion(NSError(domain: "CalendarManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Event not found."]))
            return
        }

        event.title = title
        event.startDate = startDate
        event.endDate = endDate

        do {
            try eventStoreManager.eventStore.save(event, span: .thisEvent)
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func deleteEvent(withIdentifier identifier: String, completion: @escaping (Error?) -> Void) {
        guard EKEventStore.authorizationStatus(for: .event) == .authorized else {
            completion(NSError(domain: "CalendarManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access to calendar is denied."]))
            return
        }

        guard let event = eventStoreManager.eventStore.event(withIdentifier: identifier) else {
            completion(NSError(domain: "CalendarManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Event not found."]))
            return
        }

        do {
            try eventStoreManager.eventStore.remove(event, span: .thisEvent)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
