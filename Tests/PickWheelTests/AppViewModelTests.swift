import XCTest
import EventKit
@testable import PickWheel

@MainActor
final class AppViewModelTests: XCTestCase {

    // Mirrors the pattern used in the other test files: a throwaway
    // EKEventStore per item, never saved. AppViewModel.service owns its own
    // internal EKEventStore, so these helpers must never be passed into a
    // `store.save(...)` call — EventKit does not support saving an object
    // across a different store instance than the one that created it.
    private func makeReminder(_ title: String) -> ReminderItem {
        let store = EKEventStore()
        let r = EKReminder(eventStore: store)
        r.title = title
        return ReminderItem(reminder: r)
    }

    private func makeList(_ title: String) -> ReminderList {
        let cal = EKCalendar(for: .reminder, eventStore: EKEventStore())
        cal.title = title
        return ReminderList(calendar: cal)
    }

    // MARK: - spin()

    func testSpinDoesNothingWhenAlreadySpinning() {
        let vm = AppViewModel()
        vm.reminders = [makeReminder("A")]
        vm.isSpinning = true

        vm.spin()

        XCTAssertNil(vm.selectedReminder)
        XCTAssertTrue(vm.isSpinning)
    }

    func testSpinDoesNothingWhenRemindersEmpty() {
        let vm = AppViewModel()
        vm.reminders = []
        vm.isSpinning = false

        vm.spin()

        XCTAssertFalse(vm.isSpinning)
        XCTAssertNil(vm.selectedReminder)
    }

    func testSpinPicksFromRemindersAndSetsSpinning() {
        let vm = AppViewModel()
        let items = [makeReminder("A"), makeReminder("B"), makeReminder("C")]
        vm.reminders = items
        vm.isSpinning = false

        vm.spin()

        XCTAssertTrue(vm.isSpinning)
        XCTAssertNotNil(vm.selectedReminder)
        XCTAssertTrue(items.contains(vm.selectedReminder!))
    }

    // MARK: - onSpinFinished()

    func testOnSpinFinishedStopsSpinningAndShowsResult() {
        let vm = AppViewModel()
        vm.isSpinning = true
        vm.showResult = false

        vm.onSpinFinished()

        XCTAssertFalse(vm.isSpinning)
        XCTAssertTrue(vm.showResult)
    }

    // MARK: - spinAgain()

    func testSpinAgainClearsResultState() {
        let vm = AppViewModel()
        vm.showResult = true
        vm.selectedReminder = makeReminder("A")

        vm.spinAgain()

        XCTAssertFalse(vm.showResult)
        XCTAssertNil(vm.selectedReminder)
    }

    // MARK: - deselectList()

    func testDeselectListResetsWheelAndSelectionState() {
        let vm = AppViewModel()
        vm.selectedList = makeList("Errands")
        vm.reminders = [makeReminder("A")]
        vm.selectedReminder = makeReminder("B")
        vm.showResult = true

        vm.deselectList()

        XCTAssertNil(vm.selectedList)
        XCTAssertTrue(vm.reminders.isEmpty)
        XCTAssertNil(vm.selectedReminder)
        XCTAssertFalse(vm.showResult)
    }

    // MARK: - markComplete()

    func testMarkCompleteNoopWhenNoSelection() {
        let vm = AppViewModel()
        vm.selectedReminder = nil
        vm.showResult = true

        vm.markComplete()

        // The guard returns before touching any state when nothing is selected.
        XCTAssertTrue(vm.showResult)
    }

    // MARK: - loadReminders(for:)

    func testLoadRemindersForUnknownListEndsSettledWithNoReminders() async {
        let vm = AppViewModel()
        let list = makeList("Ghost List")

        await vm.loadReminders(for: list)

        // Outcome depends on this machine's Reminders authorization state:
        // unauthorized -> fails fast with .accessDenied; authorized -> finds
        // no matching calendar and returns []. Either way, loading must end
        // and reminders must be empty — that invariant is what's under test.
        XCTAssertFalse(vm.isLoadingReminders)
        XCTAssertTrue(vm.reminders.isEmpty)
    }
}
