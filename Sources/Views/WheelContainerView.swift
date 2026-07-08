import SwiftUI

struct WheelContainerView: View {
    let vm: AppViewModel
    let list: ReminderList

    var body: some View {
        NavigationStack {
            Group {
                if vm.isLoadingReminders {
                    ProgressView("Loading reminders…")
                } else if vm.reminders.isEmpty {
                    ContentUnavailableView(
                        "No Reminders Here",
                        systemImage: "checkmark.circle",
                        description: Text("Add some reminders to \"\(list.title)\" in the Reminders app first.")
                    )
                } else {
                    VStack(spacing: 0) {
                        Spacer(minLength: 16)
                        WheelView(
                            items: vm.reminders,
                            selectedItem: vm.selectedReminder,
                            isSpinning: vm.isSpinning,
                            onSpinFinished: { vm.onSpinFinished() }
                        )
                        .padding(.horizontal, 24)

                        Spacer(minLength: 24)

                        Button {
                            vm.spin()
                        } label: {
                            Text(vm.isSpinning ? "Spinning…" : "Spin")
                                .font(.title3.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(vm.isSpinning ? Color.secondary : Color.accentColor,
                                            in: RoundedRectangle(cornerRadius: 16))
                                .foregroundStyle(.white)
                        }
                        .disabled(vm.isSpinning)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(list.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.deselectList()
                    } label: {
                        Label("Lists", systemImage: "list.bullet")
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { vm.showResult },
                set: { _ in }
            )) {
                if let winner = vm.selectedReminder {
                    ResultSheetView(
                        item: winner,
                        onMarkComplete: { vm.markComplete() },
                        onSpinAgain: { vm.spinAgain() }
                    )
                    .presentationDetents([.medium])
                }
            }
        }
    }
}
