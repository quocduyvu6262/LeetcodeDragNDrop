//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetsListView: View {
    let availableSnippets: [String]
    @Binding var currentSnippet: String
    @ObservedObject var coordinator: DragDropCoordinator

    let onDrop: (String) -> Void
    let onDragToCanvas: (String, CGPoint) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0
    @State var snippetStartPositions: [String: CGPoint] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                FlowLayout {
                    ScrollViewOffsetTracker()
                    ForEach(availableSnippets, id: \.self) { snippet in
                        CodeSnippet(code: snippet)
                            .opacity(coordinator.isDragging && coordinator.currentSnippet == snippet ? 0.5 : 1.0)
//                                .offset(coordinator.currentSnippet == snippet ? dragOffset : .zero)
                            .background(
                                GeometryReader { snippetGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Store the position when the snippet appears
                                            let frameInSolutionView = snippetGeometry.frame(in: .named("solutionView"))
                                            snippetStartPositions[snippet] = CGPoint(
                                                x: frameInSolutionView.midX,
                                                y: frameInSolutionView.midY
                                            )
                                        }
                                }
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet, source: .snippetList)
                                        }
                                        let snippetStartPosition = snippetStartPositions[snippet] ?? .zero
                                        let snippetLocation = CGPoint(
                                            x: snippetStartPosition.x + value.translation.width,
                                            y: snippetStartPosition.y + value.translation.height
                                        )
//                                        coordinator.updateDragPosition(snippetLocation)
//                                        coordinator.updateDragPosition(CGPoint(
//                                            x: 0,
//                                            y: 0
//                                        ))

                                    }
                                    .onEnded { _ in
                                        coordinator.endDrag()
                                    }
                            )
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 20)
                .padding(10.0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(true ? Color.blue : Color.primary.opacity(1.0), lineWidth: 2)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                self.scrollOffset = offset.y
            }
        }
    }
}
