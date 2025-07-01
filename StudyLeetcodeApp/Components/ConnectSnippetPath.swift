//
//  ConnectSnippetPath.swift
//  StudyLeetcodeApp
//
//  Created by Tony Vu on 6/29/25.
//

import SwiftUI


struct ConnectSnippetPath: View {
    let p1: CGPoint
    let p2: CGPoint
    let direction: String // ur, ru, dr, rd
    var body: some View {
        Path { path in
            path.move(to: p1) // Start at P1
            // --- Strategy 1: Control Point Adjusted for Gentle Curve ---
            // Calculate an intermediate point that is mostly horizontal from P1,
            // but slightly nudged towards P2's Y for a gentle bend.
            if p1.y > p2.y {
                if direction == "ru" {
                    drawCurveLShapeRightUp(path: &path, from: p1, to: p2)
                }
                else if direction == "ur" {
                    drawCurveLShapeUpRight(path: &path, from: p1, to: p2)
                }
            }
            else if p1.y < p2.y {
                if direction == "dr" {
                    drawCurveLShapeDownRight(path: &path, from: p1, to: p2)
                }
                else if direction == "rd" {
                    drawCurveLShapeRightDown(path: &path, from: p1, to: p2)
                }
            }
            let midX = (p1.x + p2.x) / 2
            let midY = (p1.y + p2.y) / 2
            let midPoint = CGPoint(x: midX, y: midY)

        }
        .stroke(Color.black, lineWidth: 2)
    }
}

extension ConnectSnippetPath {

    // right then up
    func drawCurveLShapeRightUp(path: inout Path, from p1: CGPoint, to p2: CGPoint){
        guard p1.x < p2.x else { return }
        let midX = p1.x + (p2.x - p1.x)
        let midY = p2.y + (p1.y - p2.y)
        let midPoint = CGPoint(x: midX, y: midY)

        let startBendPoint = CGPoint(x: midPoint.x - 20, y: p1.y)
        let endBendPoint = CGPoint(x: p2.x, y: p1.y - 20)

        path.move(to: p1)
        path.addLine(to: startBendPoint)
        path.addQuadCurve(to: endBendPoint, control: midPoint)
        path.addLine(to: p2)
    }

    // up then right
    func drawCurveLShapeUpRight(path: inout Path, from p1: CGPoint, to p2: CGPoint){
        guard p1.x < p2.x else { return }
        let midX = p1.x
        let midY = p2.y
        let midPoint = CGPoint(x: midX, y: midY)

        let startBendPoint = CGPoint(x: p1.x, y: p2.y + 20)
        let endBendPoint = CGPoint(x: p1.x + 20, y: p2.y)

        path.move(to: p1)
        path.addLine(to: startBendPoint)
        path.addQuadCurve(to: endBendPoint, control: midPoint)
        path.addLine(to: p2)
    }

    // down then right
    func drawCurveLShapeDownRight(path: inout Path, from p1: CGPoint, to p2: CGPoint){
        guard p1.x < p2.x else { return }
        let midX = p1.x
        let midY = p2.y
        let midPoint = CGPoint(x: midX, y: midY)

        let startBendPoint = CGPoint(x: p1.x, y: p2.y - 20)
        let endBendPoint = CGPoint(x: p1.x + 20, y: p2.y)

        path.move(to: p1)
        path.addLine(to: startBendPoint)
        path.addQuadCurve(to: endBendPoint, control: midPoint)
        path.addLine(to: p2)
    }

    // right then down
    func drawCurveLShapeRightDown(path: inout Path, from p1: CGPoint, to p2: CGPoint){
        guard p1.x < p2.x else { return }
        let midX = p2.x
        let midY = p1.y
        let midPoint = CGPoint(x: midX, y: midY)

        let startBendPoint = CGPoint(x: p2.x - 20, y: p1.y)
        let endBendPoint = CGPoint(x: p2.x, y: p1.y + 20)

        path.move(to: p1)
        path.addLine(to: startBendPoint)
        path.addQuadCurve(to: endBendPoint, control: midPoint)
        path.addLine(to: p2)
    }
}

#Preview {

    // right then up
    var p1: CGPoint = CGPoint(x: 10, y: 200)
    var p2: CGPoint = CGPoint(x: 100, y: 150)
    ConnectSnippetPath(p1: p1, p2: p2, direction: "ru")

    // up then right
    var p3 = CGPoint(x: 10, y: 200)
    var p4 = CGPoint(x: 100, y: 150)
    ConnectSnippetPath(p1: p3, p2: p4, direction: "ur")

    // up then right
    var p5 = CGPoint(x: 10, y: 100)
    var p6 = CGPoint(x: 100, y: 150)
    ConnectSnippetPath(p1: p5, p2: p6, direction: "dr")

    // up then right
    var p7 = CGPoint(x: 10, y: 100)
    var p8 = CGPoint(x: 100, y: 150)
    ConnectSnippetPath(p1: p7, p2: p8, direction: "rd")
}
