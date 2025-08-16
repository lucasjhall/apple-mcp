import Foundation
import EventKit

class MockEventStore: EKEventStore {
    var cannedEvents: [EKEvent]?
    var cannedError: Error?
    var accessGranted = true

    override func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        completion(accessGranted, cannedError)
    }

    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        return cannedEvents ?? []
    }

    override func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws {
        if let error = cannedError {
            throw error
        }
    }

    override func remove(_ event: EKEvent, span: EKSpan, commit: Bool) throws {
        if let error = cannedError {
            throw error
        }
    }

    override func event(withIdentifier identifier: String) -> EKEvent? {
        return cannedEvents?.first { $0.eventIdentifier == identifier }
    }
}
