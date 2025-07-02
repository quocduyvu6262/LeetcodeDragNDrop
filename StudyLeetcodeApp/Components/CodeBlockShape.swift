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
        guard lineRects.count >= 2 else { return path }
        let count = self.lineRects.count
        let sortedRects = lineRects.sorted { $0.key < $1.key }.map { $0.value }
        path.move(to: CGPoint(x: sortedRects[0].maxX, y: sortedRects[0].minY + cornerRadius))
        let distance = (sortedRects[1].minY - sortedRects[0].maxY) / 2

        // Draw right side
        for i in 0..<sortedRects.count {
            let currentRect = sortedRects[i]
            let nextRect: CGRect? = (i + 1 < sortedRects.count) ? sortedRects[i+1] : nil
            if i == 0 {
//                path.move(to: CGPoint(x: currentRect.maxX, y: currentRect.minY + cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.maxX, y: currentRect.maxY + distance - cornerRadius) )
            } else if i < count - 1 {
//                path.move(to: CGPoint(x: currentRect.maxX, y: currentRect.minY - distance + cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.maxX, y: currentRect.maxY + distance - cornerRadius) )
            } else {
//                path.move(to: CGPoint(x: currentRect.maxX, y: currentRect.minY - distance + cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.maxX, y: currentRect.maxY - cornerRadius) )
            }

            if let nextRect = nextRect {
                let startX = currentRect.maxX
                if nextRect.maxX > currentRect.maxX {
                    var centerPoint = CGPoint(x: startX + cornerRadius, y: currentRect.maxY + distance - cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
                    path.addLine(to: CGPoint(x: nextRect.maxX - cornerRadius, y: nextRect.minY - distance))
                    centerPoint = CGPoint(x: nextRect.maxX - cornerRadius, y: nextRect.minY - distance + cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                }
                else if nextRect.maxX < currentRect.maxX {
                    var centerPoint = CGPoint(x: startX - cornerRadius, y: currentRect.maxY - cornerRadius + distance)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                    path.addLine(to: CGPoint(x: nextRect.maxX + cornerRadius, y: nextRect.minY - distance))
                    centerPoint = CGPoint(x: nextRect.maxX + cornerRadius, y: nextRect.minY - distance + cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
                }
                else { // currentRect.maxX == nextRect.maxY
                    path.addLine(to: CGPoint(x: nextRect.maxX, y: nextRect.minY))
                }
            }
        }
//
//        // Draw bottom line
        let lastRec = sortedRects[count-1]
        var centerPoint = CGPoint(x: lastRec.maxX - cornerRadius, y: lastRec.maxY - cornerRadius)
        path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: lastRec.minX + cornerRadius, y: lastRec.maxY))
        centerPoint = CGPoint(x: lastRec.minX + cornerRadius, y: lastRec.maxY - cornerRadius)
        path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
//
//        // Draw left side (bottom up)
        for i in (0..<sortedRects.count).reversed() {
            let currentRect = sortedRects[i]
            let nextRect: CGRect? = (i > 0) ? sortedRects[i - 1] : nil
            if i == count - 1 {
//                path.move(to: CGPoint(x: currentRect.minX, y: currentRect.maxY - cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.minY - distance + cornerRadius) )
            } else if i > 0 {
//                path.move(to: CGPoint(x: currentRect.minX, y: currentRect.maxY + distance - cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.minY - distance + cornerRadius) )
            } else {
//                path.move(to: CGPoint(x: currentRect.minX, y: currentRect.maxY + distance - cornerRadius))
                path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.minY + cornerRadius) )
            }
            if let nextRect = nextRect {
                let startX = currentRect.minX
                if nextRect.minX > currentRect.minX {
                    var centerPoint = CGPoint(x: startX + cornerRadius, y: currentRect.minY - distance + cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)
                    path.addLine(to: CGPoint(x: nextRect.minX - cornerRadius, y: nextRect.maxY + distance))
                    centerPoint = CGPoint(x: nextRect.minX - cornerRadius, y: nextRect.maxY + distance - cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true)
                }
                else if nextRect.minX < currentRect.minX {
                    var centerPoint = CGPoint(x: startX - cornerRadius, y: currentRect.minY - distance + cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
                    path.addLine(to: CGPoint(x: nextRect.minX + cornerRadius, y: nextRect.maxY + distance))
                    centerPoint = CGPoint(x: nextRect.minX + cornerRadius, y: nextRect.maxY + distance - cornerRadius)
                    path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                }
                else { // currentRect.minX == nextRect.minX
                    path.addLine(to: CGPoint(x: nextRect.minX, y: nextRect.maxY))
                }
            }
        }

        // Draw top line
        let firstRec = sortedRects[0]
        centerPoint = CGPoint(x: firstRec.minX + cornerRadius, y: firstRec.minY + cornerRadius)
        path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)
        path.addLine(to: CGPoint(x: firstRec.maxX - cornerRadius, y: firstRec.minY))
        centerPoint = CGPoint(x: firstRec.maxX - cornerRadius, y: firstRec.minY + cornerRadius)
        path.addArc(center: centerPoint, radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.closeSubpath()
        return path
    }
}
