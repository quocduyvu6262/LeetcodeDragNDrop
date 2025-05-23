//
//  CanvasView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/28/25.
//

import SwiftUI

struct CanvasView: View {
    let minCanvasHeight: CGFloat
    let droppedSnippets: [(snippet: String, position: CGPoint)]
    @ObservedObject var coordinator: DragDropCoordinator
    
    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var highlightedDot: CGPoint?
    @State private var canvasHeight: CGFloat = 0
    @State private var draggedSnippetWidth: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    private var canvasFrameHeight: CGFloat
    private let canvasCoordinateSpace = "canvas"
    
    let onDrop: (String, CGPoint) -> Void
    let onDragToList: (String) -> Void

    // Add computed property for sorted snippets
    private var sortedDroppedSnippets: [(snippet: String, position: CGPoint)] {
        droppedSnippets.sorted { $0.position.y < $1.position.y }
    }

    init(minCanvasHeight: CGFloat,
         canvasFrameHeight: CGFloat,
         droppedSnippets: [(String, CGPoint)],
         coordinator: DragDropCoordinator,
         onDrop: @escaping (String, CGPoint) -> Void,
         onDragToList: @escaping (String) -> Void
    ) {
        self.minCanvasHeight = minCanvasHeight
        self._canvasHeight = State(initialValue: self.minCanvasHeight)
        self.canvasFrameHeight = canvasFrameHeight
        self.coordinator = coordinator
        self.droppedSnippets = droppedSnippets
        self.onDrop = onDrop
        self.onDragToList = onDragToList
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    ScrollViewOffsetTracker()
                    // Grid of dots
                    ForEach(0..<Int(canvasHeight / dotSpacing), id: \.self) { row in
                        ForEach(0..<Int(geometry.size.width / dotSpacing), id: \.self) { col in
                            Circle()
                                .frame(width: 3, height: 3)
                                .opacity(0.45)
                                .foregroundColor(highlightedDot == CGPoint(x: CGFloat(col) * dotSpacing, y: CGFloat(row) * dotSpacing) ? .blue : .gray)
                                .position(x: CGFloat(col) * dotSpacing, y: CGFloat(row) * dotSpacing)
                        }
                    }
                    
                    // Display dropped snippets
                    ForEach(droppedSnippets.indices, id: \.self) { index in
                        let snippet = droppedSnippets[index]
                        CodeSnippet(code: snippet.snippet)
                            .position(snippet.position)
                            .opacity(coordinator.isDragging && coordinator.currentSnippet == snippet.snippet ? 0.5 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet.snippet, source: .canvas)
                                        }
                                        let snippetInSolutionView = getGlobalPosition(for: snippet, in: geometry)
                                        let localPosition = CGPoint(
                                           x: snippet.position.x + value.translation.width,
                                           y: snippet.position.y + value.translation.height
                                        )
                                        let globalPosition = CGPoint(
                                            x: snippetInSolutionView.x + value.translation.width,
                                            y: snippetInSolutionView.y + value.translation.height
                                        )
                                        highlightedDot = nearestDot(to: localPosition, in: geometry.size)
                                        coordinator.updateDragPosition(globalPosition)
                                    }
                                    .onEnded { value in
                                        let snippetInSolutionView = getGlobalPosition(for: snippet, in: geometry)
                                        let globalPosition = CGPoint(
                                            x: snippetInSolutionView.x + value.translation.width,
                                            y: snippetInSolutionView.y + value.translation.height
                                        )
                                        if globalPosition.y > self.canvasFrameHeight {
                                            onDragToList(snippet.snippet)
                                        }
                                        else if let dot = highlightedDot {
                                            onDrop(snippet.snippet, dot)
                                        }
                                        coordinator.endDrag()
                                        highlightedDot = nil
                                    }
                            )
                    }
                    
                    // Highlighted drop zone
                    if let dot = highlightedDot, coordinator.isDragging {
                        if isSnippetInBounds(for: coordinator.currentSnippet, at: dot) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: calculateSnippetWidth(text: coordinator.currentSnippet), height: Constants.snippetHeight)
                                .cornerRadius(8)
                                .position(dot)
                        } else {
                            Rectangle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: calculateSnippetWidth(text: coordinator.currentSnippet), height: Constants.snippetHeight)
                                .cornerRadius(8)
                                .position(dot)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: max(minCanvasHeight, canvasHeight))
                .background(Color.clear.contentShape(Rectangle()))
                .clipped()
                .onChange(of: minCanvasHeight) { oldValue, newValue in
                    canvasHeight = max(canvasHeight, newValue)
                }
                .onChange(of: coordinator.dragPosition) { oldPosition, newPosition in
                    if let position = newPosition, coordinator.isDragging && coordinator.dragSource == .snippetList {
                        // Convert global position to local position for the canvas
                        let localY = position.y - self.scrollOffset
                        let localPosition = CGPoint(x: position.x, y: localY)
                        
                        // Check if position is within canvas bounds
                        if localY >= 0 && localY <= canvasFrameHeight {
                            coordinator.isOverCanvas = true
                            highlightedDot = nearestDot(to: localPosition, in: geometry.size)
                            updateCanvasHeight(for: localPosition)
                        } else {
                            coordinator.isOverCanvas = false
                            highlightedDot = nil
                        }
                    }
                }
            }
            .clipped()
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color.primary.opacity(1.0), lineWidth: 2)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                self.scrollOffset = offset.y
            }
        }
    }
    
    private func updateCanvasHeight(for point: CGPoint) {
        let requiredHeight = point.y + 100 // Add buffer for snippet height
        if requiredHeight > canvasHeight {
            canvasHeight = requiredHeight
        }
    }
    
    private func nearestDot(to location: CGPoint, in size: CGSize) -> CGPoint? {
        let x = round(location.x / dotSpacing) * dotSpacing
        let y = round(location.y / dotSpacing) * dotSpacing
        
        return CGPoint(
            x: max(0, min(x, size.width - dotSpacing)),
            y: max(0, min(y, canvasHeight - dotSpacing))
        )
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
