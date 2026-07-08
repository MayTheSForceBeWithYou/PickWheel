import EventKit
import Foundation

struct ReminderList: Identifiable, Hashable {
    let id: String
    let title: String
    let color: CGColor?

    init(calendar: EKCalendar) {
        self.id = calendar.calendarIdentifier
        self.title = calendar.title
        self.color = calendar.cgColor
    }
}
