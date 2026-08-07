import SwiftUI

struct ListPickerView: View {
    let vm: AppViewModel

    var body: some View {
        NavigationStack {
            Group {
                if vm.lists.isEmpty {
                    ContentUnavailableView(
                        "No Reminder Lists",
                        systemImage: "list.bullet.clipboard",
                        description: Text("Create a list in the Reminders app first.")
                    )
                } else {
                    List(vm.lists) { list in
                        Button {
                            vm.selectList(list)
                        } label: {
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(cgColor: list.color ?? CGColor(gray: 0.5, alpha: 1)))
                                    .frame(width: 12, height: 12)
                                    .accessibilityHidden(true)
                                Text(list.title)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.tertiary)
                                    .font(.caption)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel(list.title)
                        .accessibilityHint("Opens this list's reminders and lets you spin the wheel.")
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Pick a List")
        }
    }
}
