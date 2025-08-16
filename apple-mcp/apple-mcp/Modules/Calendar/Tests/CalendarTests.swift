import Foundation
import XCTest
import EventKit
@testable import Calendar

class CalendarTests: XCTestCase {
    var calendarManager: CalendarManager!
    var mockEventStore: MockEventStore!
    var mockEventStoreManager: EventStoreManager!

    override func setUp() {
        super.setUp()
        mockEventStore = MockEventStore()
        mockEventStoreManager = EventStoreManager(eventStore: mockEventStore)
        calendarManager = CalendarManager(eventStoreManager: mockEventStoreManager)
    }

    override func tearDown() {
        calendarManager = nil
        mockEventStore = nil
        mockEventStoreManager = nil
        super.tearDown()
    }

    func testGetEventsSuccess() {
        let event = EKEvent(eventStore: mockEventStore)
        mockEventStore.cannedEvents = [event]

        calendarManager.getEvents(from: Date(), to: Date()) { events, error in
            XCTAssertNotNil(events)
            XCTAssertEqual(events?.count, 1)
            XCTAssertNil(error)
        }
    }

    // Note: Testing the access denied case is difficult due to the static nature of
    // EKEventStore.authorizationStatus(for:). This test is omitted for now.

    func testCreateEventSuccess() {
        calendarManager.createEvent(title: "Test", startDate: Date(), endDate: Date()) { error in
            XCTAssertNil(error)
        }
    }

    func testUpdateEventSuccess() {
        let event = EKEvent(eventStore: mockEventStore)
        event.eventIdentifier = "test_identifier"
        mockEventStore.cannedEvents = [event]

        calendarManager.updateEvent(identifier: "test_identifier", title: "New Title", startDate: Date(), endDate: Date()) { error in
            XCTAssertNil(error)
        }
    }

    func testDeleteEventSuccess() {
        let event = EKEvent(eventStore: mockEventStore)
        event.eventIdentifier = "test_identifier"
        mockEventStore.cannedEvents = [event]

        calendarManager.deleteEvent(withIdentifier: "test_identifier") { error in
            XCTAssertNil(error)
        }
    }
}
