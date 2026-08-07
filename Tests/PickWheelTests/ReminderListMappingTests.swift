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

    func testReminderItemTitlePreservesEmptyString() {
        // Unlike a nil title, EventKit represents an explicitly empty title
        // as "" rather than nil, so the `?? "Untitled"` fallback in
        // ReminderItem.init never actually triggers for this case. This
        // documents the current (surprising) behavior — see code review notes.
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = ""
        let item = ReminderItem(reminder: r)
        XCTAssertEqual(item.title, "")
    }

    func testReminderItemsWithSameIdentifierDedupeInASet() {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = "Shared"
        let a = ReminderItem(reminder: r)
        let b = ReminderItem(reminder: r)
        XCTAssertEqual(Set([a, b]).count, 1)
    }
}
