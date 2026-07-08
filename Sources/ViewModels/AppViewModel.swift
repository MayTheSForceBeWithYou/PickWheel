import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class AppViewModel {
    private let service = RemindersService()

    // MARK: - Auth state
    enum AuthState {
        case loading
        case authorized
        case denied
    }

    var authState: AuthState = .loading

    // MARK: - Navigation state
    var selectedList: ReminderList? = nil

    // MARK: - Lists
    var lists: [ReminderList] = []
    var listsError: String? = nil

    // MARK: - Reminders / wheel
    var reminders: [ReminderItem] = []
    var isLoadingReminders = false
    var remindersError: String? = nil

    // MARK: - Spin state
    var isSpinning = false
    var selectedReminder: ReminderItem? = nil
    var showResult = false

    // MARK: - Lifecycle

    func onAppear() async {
        await checkAndRequestAccess()
    }

    private func checkAndRequestAccess() async {
        switch service.authStatus {
        case .authorized:
            authState = .authorized
            loadLists()
        case .denied:
            authState = .denied
        case .notDetermined:
            do {
                try await service.requestAccess()
                authState = .authorized
                loadLists()
            } catch {
                authState = .denied
            }
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Lists

    func loadLists() {
        do {
            lists = try service.fetchLists()
            listsError = nil
        } catch {
            listsError = error.localizedDescription
        }
    }

    func selectList(_ list: ReminderList) {
        selectedList = list
        Task { await loadReminders(for: list) }
    }

    func deselectList() {
        selectedList = nil
        reminders = []
        selectedReminder = nil
        showResult = false
    }

    // MARK: - Reminders

    func loadReminders(for list: ReminderList) async {
        isLoadingReminders = true
        remindersError = nil
        do {
            reminders = try await service.fetchReminders(in: list)
        } catch {
            remindersError = error.localizedDescription
        }
        isLoadingReminders = false
    }

    // MARK: - Spin

    func spin() {
        guard !isSpinning, !reminders.isEmpty else { return }
        isSpinning = true
        let winner = reminders.randomElement()!
        selectedReminder = winner
        // isSpinning will be set false by the WheelView once animation completes
    }

    func onSpinFinished() {
        isSpinning = false
        showResult = true
    }

    // MARK: - Result actions

    func markComplete() {
        guard let item = selectedReminder else { return }
        do {
            try service.markComplete(item)
            reminders.removeAll { $0.id == item.id }
        } catch {
            // Silently fail for now; could surface an alert
        }
        showResult = false
        selectedReminder = nil
    }

    func spinAgain() {
        showResult = false
        selectedReminder = nil
    }
}
