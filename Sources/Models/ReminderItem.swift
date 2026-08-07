import EventKit
import Foundation

struct ReminderItem: Identifiable, Hashable, @unchecked Sendable {
    let id: String
    let title: String
    let ekReminder: EKReminder

    init(reminder: EKReminder) {
        self.id = reminder.calendarItemIdentifier
        let rawTitle = reminder.title ?? ""
        self.title = rawTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Untitled" : rawTitle
        self.ekReminder = reminder
    }

    static func == (lhs: ReminderItem, rhs: ReminderItem) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
