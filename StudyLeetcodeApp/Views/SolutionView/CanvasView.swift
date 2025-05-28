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

    // Variables
    private let canvasCoordinateSpace = "canvas"
    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var canvasHeight: CGFloat = 0
    @State private var draggedSnippetWidth: CGFloat = 0
    @State private var isScrolling = false
    @State private var scrollEndTimer: Timer?
    @State private var snippetPositions: [String: CGRect] = [:]


    // Closures
    let onDrop: (String, CGPoint) -> Void
    let onDragToList: (String) -> Void

    // Computed Properties
    private var sortedDroppedSnippets: [(snippet: String, position: CGPoint)] {
        droppedSnippets.sorted { $0.position.y < $1.position.y }
    }
    
    private var scrollXOffset: CGFloat {
        return scrollManager.dragScrollOffset.x
    }
    
    private var scrollYOffset: CGFloat {
        return scrollManager.dragScrollOffset.y
    }
    
    var body: some View {
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
                            .background(
                                GeometryReader { snippetGeometry in
                                    Color.clear
                                        .preference(key: SnippetPositionPreferenceKey.self, value: [
                                            snippet.snippet: snippetGeometry.frame(in: .named("solutionView"))
                                        ])
                                }
                            )
                            .position(snippet.position)
                            .opacity(coordinator.isDragging && coordinator.currentSnippet == snippet.snippet ? 0.5 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard !isScrolling else { return }
                                        
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet.snippet, source: .canvas)
                                        }
                                        // Update Drag Position Over SnippetList
                                        if !coordinator.isOverCanvas, let globalPosition = getGlobalPosition(snippet: snippet.snippet, value: value) {
                                            coordinator.updateDragPosition(globalPosition)
                                        }
                                        // Update Drag Position Over Canvas
                                        else if coordinator.isOverCanvas, let consistentGlobalPosition = getConsistentGlobalPosition(snippet: snippet.snippet, value: value) {
                                            coordinator.updateDragPosition(consistentGlobalPosition)
                                        }
                                    }
                                    .onEnded { value in
                                        if let globalPosition = getGlobalPosition(snippet: snippet.snippet, value: value) {
                                            // Drop On Snippet List
                                            if globalPosition.y > self.canvasFrameHeight {
                                                onDragToList(snippet.snippet)
                                            }
                                            // Drop On Canvas
                                            else if let consistentLocalPosition = getConsistentLocalPosition(snippet: snippet.snippet, value: value) {
                                                onDrop(snippet.snippet, consistentLocalPosition)
                                            }
                                        }
                                        coordinator.endDrag()
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
                        let localPosition = CGPoint(
                            x: position.x - scrollXOffset,
                            y: position.y - scrollYOffset
                        )
                        
                        // Drag is over Canvas
                        if globalY >= 0 && globalY <= canvasFrameHeight {
                            coordinator.isOverCanvas = true
                            coordinator.isOverSnippetList = false
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
            .onPreferenceChange(SnippetPositionPreferenceKey.self) { positions in
                self.snippetPositions = positions
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                scrollManager.updateScrollOffset(offset, isDragging: coordinator.isDragging)
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
    
    private func consistentDot(to location: CGPoint) -> CGPoint {
        let x = round(location.x / dotSpacing) * dotSpacing
        let y = round(location.y / dotSpacing) * dotSpacing
        
        return CGPoint(
            x: max(0, x),
            y: max(0, y)
        )
    }
    
    private func getGlobalPosition(snippet: String, value: DragGesture.Value) -> CGPoint? {
        if let snippetFrame = snippetPositions[snippet] {
            let globalPosition = CGPoint(
                x: snippetFrame.midX + value.translation.width - 10,
                y: snippetFrame.midY + value.translation.height
            )
            return globalPosition
        }
        return nil
    }
    
    private func getConsistentLocalPosition(snippet: String, value: DragGesture.Value) -> CGPoint? {
        if let globalPosition = getGlobalPosition(snippet: snippet, value: value) {
            let localPosition = CGPoint(
                x: globalPosition.x - scrollXOffset,
                y: globalPosition.y - scrollYOffset
            )
            let consistentLocalPosition = consistentDot(to: localPosition)
            return consistentLocalPosition
        }
        return nil
    }
    
    private func getConsistentGlobalPosition(snippet: String, value: DragGesture.Value) -> CGPoint? {
        if let consistentLocalPosition = getConsistentLocalPosition(snippet: snippet, value: value) {
            let consistentGlobalPosition = CGPoint(
                x: consistentLocalPosition.x + scrollXOffset,
                y: consistentLocalPosition.y + scrollYOffset
            )
            return consistentGlobalPosition
        }
        return nil
    }
}
