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
                                DragGesture(minimumDistance: 0, coordinateSpace: .named("solutionView"))
                                    .onChanged { value in
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet, source: .snippetList)
                                        }
                                        let snippetStartPosition = snippetStartPositions[snippet] ?? .zero
                                        let snippetLocation = CGPoint(
                                            x: value.location.x,
                                            y: value.location.y
                                        )
                                        coordinator.updateDragPosition(snippetLocation)
                                    }
                                    .onEnded { value in
                                        if coordinator.isOverCanvas, let position = coordinator.dragPosition {
                                            onDragToCanvas(snippet, position)
                                        }
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
    
    private func getGlobalPosition(for snippet: (String, CGPoint), in geometry: GeometryProxy) -> CGPoint {
        let canvasFrameInSolutionView = geometry.frame(in: .named("solutionView"))
        let snippetInSolutionView = CGPoint(
            x: canvasFrameInSolutionView.minX + snippet.1.x,
            y: canvasFrameInSolutionView.minY + snippet.1.y + scrollOffset
        )
        return snippetInSolutionView
    }
}
