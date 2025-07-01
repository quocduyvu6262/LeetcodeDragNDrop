//
//  ConnectSnippetPath.swift
//  StudyLeetcodeApp
//
//  Created by Tony Vu on 6/29/25.
//

import SwiftUI

// Add this new struct to your CodeSnippet.swift file or a new file.
struct IndentedCodeBlockShape: Shape {
    let lineRects: [Int: CGRect]
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard !lineRects.isEmpty else { return path }

        let sortedRects = lineRects.sorted { $0.key < $1.key }.map { $0.value }

        // Move to the top-left corner of the first line
        path.move(to: CGPoint(x: sortedRects[0].minX + cornerRadius, y: sortedRects[0].minY))

        // Draw top and right side for each line
        for i in 0..<sortedRects.count {
            let currentRect = sortedRects[i]
            let nextRect: CGRect? = (i + 1 < sortedRects.count) ? sortedRects[i+1] : nil

            // Top edge
            path.addLine(to: CGPoint(x: currentRect.maxX - cornerRadius, y: currentRect.minY))
            // Top-right corner
            path.addArc(center: CGPoint(x: currentRect.maxX - cornerRadius, y: currentRect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            // Right edge
            path.addLine(to: CGPoint(x: currentRect.maxX, y: currentRect.maxY - cornerRadius))
            // Bottom-right corner
            path.addArc(center: CGPoint(x: currentRect.maxX - cornerRadius, y: currentRect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

            // Transition to the next line
            if let nextRect = nextRect {
                let xDifference = nextRect.minX - currentRect.minX
                if xDifference > 0 { // Indent
                    path.addLine(to: CGPoint(x: currentRect.minX + cornerRadius, y: currentRect.maxY))
                    path.addArc(center: CGPoint(x: currentRect.minX + cornerRadius, y: currentRect.maxY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: -180), clockwise: true)
                     path.addLine(to: CGPoint(x: nextRect.minX - cornerRadius, y: currentRect.maxY + cornerRadius * 2)) // This line may need tweaking based on spacing
                    path.addLine(to: CGPoint(x: nextRect.minX, y: nextRect.minY - cornerRadius))
                    path.addArc(center: CGPoint(x: nextRect.minX + cornerRadius, y: nextRect.minY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

                } else if xDifference < 0 { // Outdent
                    path.addLine(to: CGPoint(x: nextRect.minX + cornerRadius, y: currentRect.maxY))
                    path.addArc(center: CGPoint(x: nextRect.minX + cornerRadius, y: currentRect.maxY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                } else { // No change in indentation
                     path.addLine(to: CGPoint(x: nextRect.minX + cornerRadius, y: currentRect.maxY))
                     path.addLine(to: CGPoint(x: nextRect.minX + cornerRadius, y: nextRect.minY))
                }
            }
        }

        // Draw bottom and left side of the last line
        let lastRect = sortedRects.last!
        path.addLine(to: CGPoint(x: lastRect.minX + cornerRadius, y: lastRect.maxY))

        // Now, draw the left side back up to the start
        for i in (0..<sortedRects.count).reversed() {
            let currentRect = sortedRects[i]
            let prevRect: CGRect? = (i > 0) ? sortedRects[i-1] : nil

            path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.minY + cornerRadius))
            // Top-left corner
            path.addArc(center: CGPoint(x: currentRect.minX + cornerRadius, y: currentRect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)

            if let prevRect = prevRect {
                if currentRect.minX != prevRect.minX {
                     path.addLine(to: CGPoint(x: currentRect.minX + cornerRadius, y: currentRect.minY))
                     path.addLine(to: CGPoint(x: prevRect.minX + cornerRadius, y: currentRect.minY))
                }
            }
        }
        path.closeSubpath()
        return path
    }
}
