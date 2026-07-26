import SwiftUI

// MARK: - Palette

private let wheelPalette: [Color] = [
    Color(hue: 0.60, saturation: 0.28, brightness: 0.78),  // dusty blue
    Color(hue: 0.33, saturation: 0.22, brightness: 0.72),  // sage
    Color(hue: 0.08, saturation: 0.28, brightness: 0.84),  // warm terracotta
    Color(hue: 0.08, saturation: 0.06, brightness: 0.82),  // warm gray
    Color(hue: 0.55, saturation: 0.20, brightness: 0.76),  // muted teal
    Color(hue: 0.75, saturation: 0.18, brightness: 0.80),  // soft lavender
    Color(hue: 0.12, saturation: 0.30, brightness: 0.86),  // soft peach
    Color(hue: 0.40, saturation: 0.22, brightness: 0.70),  // muted olive
]

// MARK: - WheelView

struct WheelView: View {
    let items: [ReminderItem]
    let selectedItem: ReminderItem?
    let isSpinning: Bool
    let onSpinFinished: () -> Void

    @State private var rotationDegrees: Double = 0
    @State private var targetDegrees: Double = 0
    @State private var previousIsSpinning = false

    // Haptic generators
    private let impactStart = UIImpactFeedbackGenerator(style: .medium)
    private let impactLand  = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                // Wheel
                Canvas { context, canvasSize in
                    drawWheel(context: context, size: CGSize(width: size, height: size),
                              center: CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2))
                }
                .rotationEffect(.degrees(rotationDegrees))

                // Pointer at 12-o'clock
                PointerView()
                    .position(x: center.x, y: center.y - size / 2 + 2)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
        .onChange(of: isSpinning) { _, nowSpinning in
            if nowSpinning && !previousIsSpinning {
                triggerSpin()
            }
            previousIsSpinning = nowSpinning
        }
    }

    // MARK: - Spin trigger

    private func triggerSpin() {
        guard let winner = selectedItem,
              let index = items.firstIndex(of: winner) else { return }

        impactStart.impactOccurred()

        let wedgeAngle = 360.0 / Double(items.count)
        // Centre of the winning wedge (measured from top = 0, clockwise)
        let wedgeCenter = wedgeAngle * Double(index) + wedgeAngle / 2
        // We want the wheel to rotate so that wedgeCenter lands under the pointer (top).
        // The wheel starts with wedge 0 at top; rotate so winner ends at top.
        let fullRotations = Double(Int.random(in: 5...8)) * 360.0
        let landingOffset = 360.0 - wedgeCenter + Double.random(in: -(wedgeAngle * 0.35)...(wedgeAngle * 0.35))
        targetDegrees = rotationDegrees + fullRotations + landingOffset

        withAnimation(.timingCurve(0.2, 0.8, 0.3, 1.0, duration: 4.0)) {
            rotationDegrees = targetDegrees
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            impactLand.impactOccurred()
            onSpinFinished()
        }
    }

    // MARK: - Drawing

    private func drawWheel(context: GraphicsContext, size: CGSize, center: CGPoint) {
        let radius = min(size.width, size.height) / 2
        let count = items.count
        guard count > 0 else { return }
        let wedgeAngle = (2 * Double.pi) / Double(count)
        // Start at top (-π/2)
        let startOffset = -Double.pi / 2

        for i in 0..<count {
            let startAngle = startOffset + Double(i) * wedgeAngle
            let endAngle   = startAngle + wedgeAngle

            // Fill wedge
            var wedgePath = Path()
            wedgePath.move(to: center)
            wedgePath.addArc(center: center, radius: radius,
                             startAngle: .radians(startAngle),
                             endAngle: .radians(endAngle),
                             clockwise: false)
            wedgePath.closeSubpath()

            let color = wheelPalette[i % wheelPalette.count]
            context.fill(wedgePath, with: .color(color))

            // Stroke separator
            context.stroke(wedgePath, with: .color(.white.opacity(0.6)), lineWidth: 1.5)

            // Label
            drawLabel(context: context, center: center, radius: radius,
                      startAngle: startAngle, endAngle: endAngle,
                      text: items[i].title)
        }

        // Outer ring
        let ring = Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                                          width: radius * 2, height: radius * 2))
        context.stroke(ring, with: .color(.white.opacity(0.8)), lineWidth: 2)
    }

    private func drawLabel(context: GraphicsContext, center: CGPoint, radius: CGFloat,
                           startAngle: Double, endAngle: Double, text: String) {
        let midAngle = (startAngle + endAngle) / 2
        let labelRadius = radius * 0.62
        let labelX = center.x + CGFloat(cos(midAngle)) * labelRadius
        let labelY = center.y + CGFloat(sin(midAngle)) * labelRadius

        let maxWidth = radius * 0.55
        let font = Font.system(size: max(10, min(15, radius * 0.09)))
        let resolved = context.resolve(
            Text(text)
                .font(font)
                .foregroundStyle(Color.white.opacity(0.95))
        )

        // Rotate text to read radially, center outward
        var labelContext = context
        labelContext.translateBy(x: labelX, y: labelY)
        let rotationAngle = midAngle
        labelContext.rotate(by: .radians(rotationAngle))
        labelContext.draw(resolved, in: CGRect(x: -maxWidth / 2, y: -16, width: maxWidth, height: 32))
    }
}

// MARK: - Pointer

struct PointerView: View {
    var body: some View {
        ZStack {
            Triangle()
                .fill(Color(hue: 0.08, saturation: 0.55, brightness: 0.75))
                .frame(width: 20, height: 28)
                .shadow(radius: 3, y: 2)
            Triangle()
                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                .frame(width: 20, height: 28)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            p.closeSubpath()
        }
    }
}
