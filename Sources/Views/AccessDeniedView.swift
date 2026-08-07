import SwiftUI

struct AccessDeniedView: View {
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Reminders Access Needed")
                    .font(.title2.bold())
                Text("PickWheel needs access to your Reminders to build the wheel. Please grant access in Settings.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: onOpenSettings) {
                Label("Open Settings", systemImage: "gear")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.tint, in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
            }
            .accessibilityHint("Opens the Settings app so you can allow PickWheel to access Reminders.")
        }
        .padding(32)
    }
}
