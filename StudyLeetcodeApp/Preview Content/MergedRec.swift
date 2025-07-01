import SwiftUI

/// A custom SwiftUI Shape that connects two rectangles that are not
/// perfectly aligned vertically, creating a smooth, merged appearance.
struct OffsetMergedRectangles: Shape {
    /// The horizontal offset of the bottom rectangle relative to the top one.
    /// Positive values shift it right, negative values shift it left.
    var horizontalOffset: CGFloat

    /// The height of the smooth connecting section.
    var connectionHeight: CGFloat

    /// Initializes the shape with the offset and connection height.
    /// - Parameters:
    ///   - horizontalOffset: The horizontal displacement of the bottom rect.
    ///   - connectionHeight: The vertical space dedicated to the curve.
    init(horizontalOffset: CGFloat, connectionHeight: CGFloat = 50) {
        self.horizontalOffset = horizontalOffset
        self.connectionHeight = connectionHeight
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Define the two conceptual rectangles based on the total 'rect' bounds.
        // Adjust these relative heights as needed.
        let topRectHeight = (rect.height - connectionHeight) / 2
        let bottomRectHeight = (rect.height - connectionHeight) / 2

        // Top Rectangle (always at the top-left of the overall 'rect')
        let topRect = CGRect(x: rect.minX,
                             y: rect.minY,
                             width: rect.width,
                             height: topRectHeight)

        // Bottom Rectangle (offset horizontally)
        let bottomRect = CGRect(x: rect.minX + horizontalOffset,
                                y: rect.minY + topRectHeight + connectionHeight, // Placed below topRect with connection space
                                width: rect.width,
                                height: bottomRectHeight)

        // --- Drawing the Path ---

        // Start from the top-left corner of the top rectangle
        path.move(to: CGPoint(x: topRect.minX, y: topRect.minY))

        // Draw top edge of the top rectangle
        path.addLine(to: CGPoint(x: topRect.maxX, y: topRect.minY))

        // Draw right edge of the top rectangle
        path.addLine(to: CGPoint(x: topRect.maxX, y: topRect.maxY))

        // --- Create the RIGHT-SIDE smooth curve connecting top to bottom ---
        // This curve will go from the bottom-right of topRect
        // to the top-right of bottomRect.
        path.addCurve(to: CGPoint(x: bottomRect.maxX, y: bottomRect.minY),
                      control1: CGPoint(x: topRect.maxX, y: topRect.maxY + connectionHeight * 0.5), // Pull right
                      control2: CGPoint(x: bottomRect.maxX, y: bottomRect.minY - connectionHeight * 0.5)) // Pull right

        // Draw bottom edge of the bottom rectangle
        path.addLine(to: CGPoint(x: bottomRect.minX, y: bottomRect.maxY))

        // Draw left edge of the bottom rectangle
        path.addLine(to: CGPoint(x: bottomRect.minX, y: bottomRect.minY))

        // --- Create the LEFT-SIDE smooth curve connecting bottom to top ---
        // This curve will go from the top-left of bottomRect
        // back to the bottom-left of topRect.
        path.addCurve(to: CGPoint(x: topRect.minX, y: topRect.maxY),
                      control1: CGPoint(x: bottomRect.minX, y: bottomRect.minY - connectionHeight * 0.5), // Pull left
                      control2: CGPoint(x: topRect.minX, y: topRect.maxY + connectionHeight * 0.5)) // Pull left

        // Close the path (connects back to the starting point: top-left of topRect)
        path.closeSubpath()

        return path
    }
}

// --- SwiftUI View to display the offset merged rectangles ---

struct OffsetMergedRectanglesView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("Offset Merged Rectangles")
                .font(.title)
                .bold()
                .foregroundColor(.primary)

            // Example 1: Bottom rectangle shifted right
            OffsetMergedRectangles(horizontalOffset: 80, connectionHeight: 60)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .top, endPoint: .bottom))
                .frame(width: 200, height: 350)
                .shadow(color: Color.black.opacity(0.25), radius: 12, x: 5, y: 8)
                .overlay(
                    VStack {
                        Text("Top Section")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                        Spacer()
                        Text("Bottom Section\n(Offset Right)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 20)
                    }
                )

            // Example 2: Bottom rectangle shifted left with different colors
            OffsetMergedRectangles(horizontalOffset: -50, connectionHeight: 40)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.cyan, Color.blue]), startPoint: .top, endPoint: .bottom))
                .frame(width: 180, height: 280)
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: -3, y: 5)
                .overlay(
                    VStack {
                        Text("Top Section")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                        Spacer()
                        Text("Bottom Section\n(Offset Left)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 15)
                    }
                )

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05).edgesIgnoringSafeArea(.all))
    }
}

// --- Preview Provider ---

struct OffsetMergedRectanglesView_Previews: PreviewProvider {
    static var previews: some View {
        OffsetMergedRectanglesView()
    }
}
