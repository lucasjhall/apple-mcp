import Foundation
import EventKit

class EventManager {
    private let calendarManager: CalendarManager

    init(calendarManager: CalendarManager = CalendarManager()) {
        self.calendarManager = calendarManager
    }

    func getEvents(from startDate: Date, to endDate: Date, completion: @escaping ([Event]?, Error?) -> Void) {
        calendarManager.getEvents(from: startDate, to: endDate) { ekEvents, error in
            if let error = error {
                completion(nil, error)
                return
            }

            if let ekEvents = ekEvents {
                let events = ekEvents.map { Event(identifier: $0.eventIdentifier, title: $0.title, startDate: $0.startDate, endDate: $0.endDate) }
                completion(events, nil)
            } else {
                completion([], nil)
            }
        }
    }

    func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        calendarManager.createEvent(title: title, startDate: startDate, endDate: endDate, completion: completion)
    }

    func updateEvent(_ event: Event, completion: @escaping (Error?) -> Void) {
        guard let identifier = event.identifier else {
            completion(NSError(domain: "EventManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Event has no identifier."]))
            return
        }

        calendarManager.updateEvent(identifier: identifier, title: event.title, startDate: event.startDate, endDate: event.endDate, completion: completion)
    }

    func deleteEvent(_ event: Event, completion: @escaping (Error?) -> Void) {
        guard let identifier = event.identifier else {
            completion(NSError(domain: "EventManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Event has no identifier."]))
            return
        }

        calendarManager.deleteEvent(withIdentifier: identifier, completion: completion)
    }
}
