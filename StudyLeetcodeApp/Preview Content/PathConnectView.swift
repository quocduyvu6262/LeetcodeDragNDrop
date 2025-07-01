//
//  PathConnectView.swift
//  StudyLeetcodeApp
//
//  Created by Tony Vu on 6/29/25.
//

import SwiftUI

struct PathConnectView: View {
    // Define your two points
    let p1: CGPoint = CGPoint(x: 20, y: 200)
    let p2: CGPoint = CGPoint(x: 250, y: 150)

    var body: some View {
        ZStack { // Use ZStack to layer the points and the path

            // Optional: Draw the points themselves for visualization
            Circle()
                .frame(width: 10, height: 10)
                .position(p1)
                .foregroundColor(.blue)

            Circle()
                .frame(width: 10, height: 10)
                .position(p2)
                .foregroundColor(.red)

            // Text labels for P1 and P2
            Text("P1")
                .position(x: p1.x - 20, y: p1.y - 10)
                .font(.caption)

            Text("P2")
                .position(x: p2.x + 20, y: p2.y + 10)
                .font(.caption)

            // The Path connecting P1 and P2 with a gentle curve
            Path { path in
                path.move(to: p1) // Start at P1

                // --- Strategy 1: Control Point Adjusted for Gentle Curve ---
                // Calculate an intermediate point that is mostly horizontal from P1,
                // but slightly nudged towards P2's Y for a gentle bend.
                let midX = p1.x + (p2.x - p1.x) * 0.7 // Go 70% of the way horizontally
                let midY = p1.y // Stay at P1's Y initially

                // The control point will be somewhere along the 'horizontal' part,
                // but its Y will be slightly influenced by p2.y.
                // Or, simply the 'corner' point for a subtle curve.
                let controlPoint = CGPoint(x: p2.x, y: p1.y) // This is the L-bend corner

                // Add the quadratic Bézier curve.
                // We'll use intermediate points for a more controlled "soft L-shape".
                // This means we might need multiple segments.

                // First segment: from P1 to a point just before the bend
                let startBendX = p1.x + (p2.x - p1.x) * 0.9 // Horizontal part from P1
                let startBendPoint = CGPoint(x: startBendX, y: p1.y)
                path.addLine(to: startBendPoint) // Draw a straight line first

                // Second segment: the actual gentle curve
                // The end point of this curve is where the horizontal segment turns vertical.
                let endBendPoint = CGPoint(x: p2.x, y: p1.y + (p2.y - p1.y) * 0.2) // A point closer to P2's Y but not all the way
                let curveControlPoint = CGPoint(x: p2.x, y: p1.y) // Control point at the sharp L-corner

                path.addQuadCurve(to: endBendPoint, control: curveControlPoint)

                // Third segment: from the end of the curve to P2
                path.addLine(to: p2) // Go vertical to P2


                // --- Alternatively, for a single, less extreme curve ---
                // If you want just ONE curve from P1 to P2, but not as dramatic:
                // The control point's Y could be closer to the midpoint of P1.y and P2.y
                // let lessExtremeControlPoint = CGPoint(x: p2.x, y: p1.y + (p2.y - p1.y) / 4) // Adjust the Y closer to P1.y
                // path.addQuadCurve(to: p2, control: lessExtremeControlPoint)
                // This will still have a clear bend, but less of a 'pull' towards the extreme corner.

            }
            .stroke(Color.black, lineWidth: 2) // Style the line
        }
        .frame(width: 300, height: 200) // Frame for the ZStack
        .border(Color.gray) // Optional: Add a border to see the frame boundaries
    }
}

struct PathConnectView_Previews: PreviewProvider {
    static var previews: some View {
        PathConnectView()
    }
}
