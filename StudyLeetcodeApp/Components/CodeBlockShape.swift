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

        path.move(to: CGPoint(x: sortedRects[0].maxX, y: sortedRects[0].minY))

        // Draw right side
        for i in 0..<sortedRects.count {
            let currentRect = sortedRects[i]
            let nextRect: CGRect? = (i + 1 < sortedRects.count) ? sortedRects[i+1] : nil
            path.addLine(to: CGPoint(x: currentRect.maxX, y: currentRect.maxY) )
            if let nextRect = nextRect {
                let midY = currentRect.maxY + (nextRect.minY - currentRect.maxY) / 2
                let diff = midY - currentRect.maxY
                let startX = currentRect.maxX
                if nextRect.maxX > currentRect.maxX {
                    var centerPoint = CGPoint(x: startX + diff, y: currentRect.maxY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
                    path.addLine(to: CGPoint(x: nextRect.maxX - diff, y: nextRect.minY - diff))
                    centerPoint = CGPoint(x: nextRect.maxX - diff, y: nextRect.minY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                }
                else if nextRect.maxX < currentRect.maxX {
                    var centerPoint = CGPoint(x: startX - diff, y: currentRect.maxY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                    path.addLine(to: CGPoint(x: nextRect.maxX + diff, y: nextRect.minY - diff))
                    centerPoint = CGPoint(x: nextRect.maxX + diff, y: nextRect.minY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
                }
                else { // currentRect.maxX == nextRect.maxY
                    path.addLine(to: CGPoint(x: nextRect.maxX, y: nextRect.minY))
                }
            }
        }

        // Draw left side
//        for i in 0..<sortedRects.count {
//            let currentRect = sortedRects[i]
//            path.move(to: CGPoint(x: currentRect.minX, y: currentRect.minY))
//            let nextRect: CGRect? = (i + 1 < sortedRects.count) ? sortedRects[i+1] : nil
//            path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.maxY) )
//            if let nextRect = nextRect {
//                let midY = currentRect.maxY + (nextRect.minY - currentRect.maxY) / 2
//                let diff = midY - currentRect.maxY
//                let startX = currentRect.minX
//                if nextRect.minX > currentRect.minX {
//                    var centerPoint = CGPoint(x: startX + diff, y: currentRect.maxY)
//                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
//                    path.addLine(to: CGPoint(x: nextRect.minX - diff, y: nextRect.minY - diff))
//                    centerPoint = CGPoint(x: nextRect.minX - diff, y: nextRect.minY)
//                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
//                }
//                else if nextRect.minX < currentRect.minX {
//                    var centerPoint = CGPoint(x: startX - diff, y: currentRect.maxY)
//                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
//                    path.addLine(to: CGPoint(x: nextRect.minX + diff, y: nextRect.minY - diff))
//                    centerPoint = CGPoint(x: nextRect.minX + diff, y: nextRect.minY)
//                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 180), clockwise: true)
//                }
//                else { // currentRect.minX == nextRect.minX
//                    path.addLine(to: CGPoint(x: nextRect.minX, y: nextRect.minY))
//                }
//            }
//        }

        // Draw bottom line
        let count = sortedRects.count
        let lastRec = sortedRects[count-1]
        path.addLine(to: CGPoint(x: lastRec.minX, y: lastRec.maxY))

        // Draw left side (bottom up)
        for i in (0..<sortedRects.count).reversed() {
            let currentRect = sortedRects[i]
            let nextRect: CGRect? = (i > 0) ? sortedRects[i - 1] : nil
            path.addLine(to: CGPoint(x: currentRect.minX, y: currentRect.minY) )
            if let nextRect = nextRect {
                let midY = currentRect.minY - (currentRect.minY - nextRect.maxY) / 2
                let diff = midY - nextRect.maxY
                let startX = currentRect.minX
                if nextRect.minX > currentRect.minX {
                    var centerPoint = CGPoint(x: startX + diff, y: currentRect.minY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: -90), clockwise: false)
                    path.addLine(to: CGPoint(x: nextRect.minX - diff, y: nextRect.maxY + diff))
                    centerPoint = CGPoint(x: nextRect.minX - diff, y: nextRect.maxY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true)
                }
                else if nextRect.minX < currentRect.minX {
                    var centerPoint = CGPoint(x: startX - diff, y: currentRect.minY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)
                    path.addLine(to: CGPoint(x: nextRect.minX + diff, y: nextRect.maxY + diff))
                    centerPoint = CGPoint(x: nextRect.minX + diff, y: nextRect.maxY)
                    path.addArc(center: centerPoint, radius: diff, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                }
                else { // currentRect.minX == nextRect.minX
                    path.addLine(to: CGPoint(x: nextRect.minX, y: nextRect.minY))
                }
            }
        }

        // Draw top line
        let firstRec = sortedRects[0]
        path.addLine(to: CGPoint(x: firstRec.maxX, y: firstRec.minY))

        path.closeSubpath()
        return path
    }
}
