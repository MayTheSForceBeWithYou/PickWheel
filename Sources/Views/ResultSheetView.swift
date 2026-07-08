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
                Text(item.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 32)

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

                Button(action: onSpinAgain) {
                    Label("Spin Again", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
