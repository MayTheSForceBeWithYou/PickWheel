import XCTest
import EventKit
@testable import PickWheel

final class RandomSelectionTests: XCTestCase {

    func testRandomElementAlwaysInSet() {
        let store = EKEventStore()
        let items = (1...10).map { i -> ReminderItem in
            let r = EKReminder(eventStore: store)
            r.title = "Task \(i)"
            return ReminderItem(reminder: r)
        }

        for _ in 0..<50 {
            let pick = items.randomElement()
            XCTAssertNotNil(pick)
            XCTAssertTrue(items.contains(pick!))
        }
    }

    func testSingleItemRandomElement() {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = "Solo task"
        let item = ReminderItem(reminder: r)
        let items = [item]
        XCTAssertEqual(items.randomElement()?.id, item.id)
    }

    func testReminderItemIDStability() {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = "Stable"
        let a = ReminderItem(reminder: r)
        let b = ReminderItem(reminder: r)
        XCTAssertEqual(a.id, b.id)
    }
}
