import EventKit
import Foundation

class EventStoreManager {
    static let shared = EventStoreManager()
    var eventStore: EKEventStore

    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
        requestAccess { _, _ in }
    }

    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            completion(granted, error)
        }
    }
}
