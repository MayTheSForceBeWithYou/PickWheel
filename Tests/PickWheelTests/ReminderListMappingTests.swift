import XCTest
import EventKit
@testable import PickWheel

final class ReminderListMappingTests: XCTestCase {

    func testReminderListMapsTitle() {
        let store = EKEventStore()
        let cal = EKCalendar(for: .reminder, eventStore: store)
        cal.title = "Work Tasks"
        let list = ReminderList(calendar: cal)
        XCTAssertEqual(list.title, "Work Tasks")
    }

    func testReminderListMapsID() {
        let store = EKEventStore()
        let cal = EKCalendar(for: .reminder, eventStore: store)
        let list = ReminderList(calendar: cal)
        XCTAssertEqual(list.id, cal.calendarIdentifier)
    }

    func testReminderItemTitleFallsBackToUntitled() {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = nil
        let item = ReminderItem(reminder: r)
        XCTAssertEqual(item.title, "Untitled")
    }

    func testReminderItemTitleUsesReminderTitle() {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = "Buy groceries"
        let item = ReminderItem(reminder: r)
        XCTAssertEqual(item.title, "Buy groceries")
    }
}
