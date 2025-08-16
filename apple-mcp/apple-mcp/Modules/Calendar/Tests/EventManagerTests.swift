import Foundation
import XCTest
import EventKit
@testable import Calendar

class EventManagerTests: XCTestCase {
    var eventManager: EventManager!
    var mockCalendarManager: MockCalendarManager!

    override func setUp() {
        super.setUp()
        mockCalendarManager = MockCalendarManager()
        eventManager = EventManager(calendarManager: mockCalendarManager)
    }

    override func tearDown() {
        eventManager = nil
        mockCalendarManager = nil
        super.tearDown()
    }

    func testGetEventsSuccess() {
        let event = EKEvent()
        mockCalendarManager.cannedEvents = [event]

        eventManager.getEvents(from: Date(), to: Date()) { events, error in
            XCTAssertNotNil(events)
            XCTAssertEqual(events?.count, 1)
            XCTAssertNil(error)
        }
    }

    func testCreateEventSuccess() {
        eventManager.createEvent(title: "Test", startDate: Date(), endDate: Date()) { error in
            XCTAssertNil(error)
        }
    }

    func testUpdateEventSuccess() {
        let event = Event(identifier: "test_identifier", title: "Test", startDate: Date(), endDate: Date())

        eventManager.updateEvent(event) { error in
            XCTAssertNil(error)
        }
    }

    func testDeleteEventSuccess() {
        let event = Event(identifier: "test_identifier", title: "Test", startDate: Date(), endDate: Date())

        eventManager.deleteEvent(event) { error in
            XCTAssertNil(error)
        }
    }
}

class MockCalendarManager: CalendarManager {
    var cannedEvents: [EKEvent]?
    var cannedError: Error?

    init() {
        super.init(eventStoreManager: EventStoreManager(eventStore: MockEventStore()))
    }

    override func getEvents(from startDate: Date, to endDate: Date, completion: @escaping ([EKEvent]?, Error?) -> Void) {
        completion(cannedEvents, cannedError)
    }

    override func createEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        completion(cannedError)
    }

    override func updateEvent(identifier: String, title: String, startDate: Date, endDate: Date, completion: @escaping (Error?) -> Void) {
        completion(cannedError)
    }

    override func deleteEvent(withIdentifier identifier: String, completion: @escaping (Error?) -> Void) {
        completion(cannedError)
    }
}
