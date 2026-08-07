import SwiftUI

struct ResultSheetView: View {
    let item: ReminderItem
    let onMarkComplete: () -> Void
    let onSpinAgain: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 12) {
                Text("🎉")
                    .font(.system(size: 52))
                    .accessibilityHidden(true)
                Text(item.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 32)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("You picked: \(item.title)")

            Spacer()

            VStack(spacing: 12) {
                Button(action: onMarkComplete) {
                    Label("Mark Complete", systemImage: "checkmark.circle.fill")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(hue: 0.33, saturation: 0.22, brightness: 0.60),
                                    in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .accessibilityHint("Marks \"\(item.title)\" as done and removes it from the wheel.")

                Button(action: onSpinAgain) {
                    Label("Spin Again", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }
                .accessibilityHint("Keeps \"\(item.title)\" in the list and spins the wheel again.")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
