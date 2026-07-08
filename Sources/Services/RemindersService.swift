@preconcurrency import EventKit
import Foundation

enum RemindersAuthStatus {
    case notDetermined
    case authorized
    case denied
}

enum RemindersError: Error {
    case accessDenied
    case fetchFailed(Error)
    case saveFailed(Error)
}

final class RemindersService: Sendable {
    nonisolated(unsafe) private let store = EKEventStore()

    // MARK: - Authorization

    var authStatus: RemindersAuthStatus {
        switch EKEventStore.authorizationStatus(for: .reminder) {
        case .authorized, .fullAccess: return .authorized
        case .denied, .restricted: return .denied
        case .notDetermined, .writeOnly: return .notDetermined
        @unknown default: return .notDetermined
        }
    }

    func requestAccess() async throws {
        let granted = try await store.requestFullAccessToReminders()
        if !granted {
            throw RemindersError.accessDenied
        }
    }

    // MARK: - Lists

    func fetchLists() throws -> [ReminderList] {
        guard authStatus == .authorized else { throw RemindersError.accessDenied }
        let calendars = store.calendars(for: .reminder)
        return calendars.map { ReminderList(calendar: $0) }
    }

    func ekCalendar(for list: ReminderList) -> EKCalendar? {
        store.calendars(for: .reminder).first { $0.calendarIdentifier == list.id }
    }

    // MARK: - Reminders

    func fetchReminders(in list: ReminderList) async throws -> [ReminderItem] {
        guard authStatus == .authorized else { throw RemindersError.accessDenied }
        guard let calendar = ekCalendar(for: list) else { return [] }

        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: [calendar]
        )

        return try await withCheckedThrowingContinuation { continuation in
            store.fetchReminders(matching: predicate) { fetched in
                let items = (fetched ?? []).map { ReminderItem(reminder: $0) }
                continuation.resume(returning: items)
            }
        }
    }

    // MARK: - Mark Complete

    func markComplete(_ item: ReminderItem) throws {
        guard authStatus == .authorized else { throw RemindersError.accessDenied }
        let reminder = item.ekReminder
        reminder.isCompleted = true
        do {
            try store.save(reminder, commit: true)
        } catch {
            throw RemindersError.saveFailed(error)
        }
    }
}
