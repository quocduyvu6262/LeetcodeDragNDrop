//
//  CanvasView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/28/25.
//

import SwiftUI

struct CanvasView: View {
    // Parameters
    let minCanvasHeight: CGFloat
    var canvasFrameHeight: CGFloat
    let droppedSnippets: [(snippet: String, position: CGPoint)]
    @ObservedObject var coordinator: DragDropCoordinator
    @ObservedObject var scrollManager: ScrollOffsetManager
    @Binding var highlightedDot: CGPoint?

    // Variables
    private let canvasCoordinateSpace = "canvas"
    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var canvasHeight: CGFloat = 0
    @State private var draggedSnippetWidth: CGFloat = 0
    @State private var isScrolling = false
    @State private var scrollEndTimer: Timer?

    // Closure
    let onDrop: (String, CGPoint) -> Void
    let onDragToList: (String) -> Void

    // Computed Property
    private var sortedDroppedSnippets: [(snippet: String, position: CGPoint)] {
        droppedSnippets.sorted { $0.position.y < $1.position.y }
    }
    
    private var scrollOffset: CGFloat {
        return scrollManager.dragScrollOffset
    }
    
    var body: some View {
        let _ = print("CanvasView rendered")
        GeometryReader { geometry in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    ScrollViewOffsetTracker()
                    // Grid of dots
                    ForEach(0..<Int(canvasHeight / dotSpacing), id: \.self) { row in
                        ForEach(0..<2 * Int(geometry.size.width / dotSpacing), id: \.self) { col in
                            Circle()
                                .frame(width: 3, height: 3)
                                .opacity(0.3)
                                .foregroundColor(.gray)
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
                                        guard !isScrolling else { return }
                                        
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet.snippet, source: .canvas)
                                        }
                                        let localPosition = CGPoint(
                                           x: snippet.position.x + value.translation.width,
                                           y: snippet.position.y + value.translation.height
                                        )
                                        // Update Drag Position Over Canvas
                                        if coordinator.isOverCanvas {
                                            if let dot = nearestDot(to: localPosition, in: geometry.size) {
                                                coordinator.updateDragPosition(CGPoint(
                                                    x: dot.x,
                                                    y: dot.y + scrollOffset
                                                ))
                                            }
                                        // Update Drag Position Over SnippetList
                                        }
                                        else if coordinator.isOverSnippetList {
                                            let globalPosition = CGPoint(
                                                x: localPosition.x,
                                                y: localPosition.y + scrollOffset
                                            )
                                            coordinator.updateDragPosition(globalPosition)
                                        }
                                    }
                                    .onEnded { value in
                                        let snippetInSolutionView = getGlobalPosition(for: snippet, in: geometry)
                                        let globalPosition = CGPoint(
                                            x: snippetInSolutionView.x + value.translation.width,
                                            y: snippetInSolutionView.y + value.translation.height
                                        )
                                        
                                        // Drop On Snippet List
                                        if globalPosition.y > self.canvasFrameHeight {
                                            onDragToList(snippet.snippet)
                                        }
                                        // Drop On Canvas
                                        else if let dot = highlightedDot {
                                            onDrop(snippet.snippet, dot)
                                        }
                                        coordinator.endDrag()
                                        highlightedDot = nil
                                    }
                            )
                    }
                }
                .frame(width: geometry.size.width * 1.5, height: max(minCanvasHeight, canvasHeight))
                .background(Color.clear.contentShape(Rectangle()))
                .onChange(of: minCanvasHeight) { oldValue, newValue in
                    canvasHeight = max(canvasHeight, newValue)
                }
                // Drop detection from when dragging from SnippetList
                .onChange(of: coordinator.dragPosition) { oldPosition, newPosition in
                    if let position = newPosition, coordinator.isDragging {
                        let globalY = position.y
                        let localY = position.y - scrollOffset
                        let localPosition = CGPoint(x: position.x, y: localY)
                        
                        // Drag is over Canvas
                        if globalY >= 0 && globalY <= canvasFrameHeight {
                            coordinator.isOverCanvas = true
                            coordinator.isOverSnippetList = false
                            highlightedDot = nearestDot(to: localPosition, in: geometry.size)
                            updateCanvasHeight(for: localPosition)
                        // Drag is over SnippetList
                        } else {
                            coordinator.isOverCanvas = false
                            coordinator.isOverSnippetList = true
                        }
                    }
                }
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                scrollManager.updateScrollOffset(offset.y, isDragging: coordinator.isDragging)
                self.isScrolling = true
                
                // Reset scrolling state after a brief delay
                scrollEndTimer?.invalidate()
                scrollEndTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { _ in
                    self.isScrolling = false
                }
            }
        }
        .clipped()
        .overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(Color.primary.opacity(1.0), lineWidth: 2)
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
