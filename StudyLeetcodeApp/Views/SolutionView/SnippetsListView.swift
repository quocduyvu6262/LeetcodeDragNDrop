//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [CodeSnippetType: CGRect] = [:]

    static func reduce(value: inout [CodeSnippetType: CGRect], nextValue: () -> [CodeSnippetType: CGRect]) {
        value.merge(nextValue()) { current, _ in current }
    }
}

struct SnippetsListView: View {
    // Parameters
    let availableSnippets: [CodeSnippetType]
    @ObservedObject var coordinator: DragDropCoordinator
    @ObservedObject var scrollManager: ScrollOffsetManager
    
    // Variables
    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var dragOffset: CGSize = .zero
    @State private var snippetPositions: [CodeSnippetType: CGRect] = [:]
    @State private var isScrolling = false
    @State private var scrollEndTimer: Timer?
    
    // Closure
    let onDragToCanvas: (CodeSnippetType, CGPoint) -> Void

    // Computed Property
    private var scrollXOffset: CGFloat {
        return scrollManager.dragScrollOffset.x
    }
    
    private var scrollYOffset: CGFloat {
        return scrollManager.dragScrollOffset.y
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.vertical], showsIndicators: true) {
                FlowLayout {
                    ScrollViewOffsetTracker()
                    ForEach(availableSnippets, id: \.self) { snippet in
                        CodeSnippet(code: snippet.text)
                            .background(
                                GeometryReader { snippetGeometry in
                                    Color.clear
                                        .preference(key: SnippetPositionPreferenceKey.self, value: [
                                            snippet: snippetGeometry.frame(in: .named("solutionView"))
                                        ])
                                }
                            )
                            .opacity(coordinator.isDragging && coordinator.currentSnippet == snippet ? 0.5 : 1.0)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        guard !isScrolling else { return }
                                        
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet, source: .snippetList)
                                        }
                                        // Update Drag Position Over SnippetList
                                        if !coordinator.isOverCanvas, let globalPosition = getGlobalPosition(snippet: snippet, value: value) {
                                            coordinator.updateDragPosition(globalPosition)
                                        }
                                        // Update Drag Position Over Canvas
                                        else if coordinator.isOverCanvas, let consistentGlobalPosition = getConsistentGlobalPosition(snippet: snippet, value: value) {
                                            coordinator.updateDragPosition(consistentGlobalPosition)
                                        }
                                    }
                                    .onEnded { value in
                                        if coordinator.isOverCanvas, let dot = getConsistentLocalPosition(snippet: snippet, value: value) {
                                            // Drop on Canvas. Otherwise do nothing
                                            onDragToCanvas(snippet, dot)
                                        }
                                        coordinator.endDrag()
                                    }
                            )
                    }
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(SnippetPositionPreferenceKey.self) { positions in
                self.snippetPositions = positions
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { _ in
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
    
    private func getGlobalPosition(snippet: CodeSnippetType, value: DragGesture.Value) -> CGPoint? {
        if let snippetFrame = snippetPositions[snippet] {
            let globalPosition = CGPoint(
                x: snippetFrame.midX + value.translation.width - 10,
                y: snippetFrame.midY + value.translation.height
            )
            return globalPosition
        }
        return nil
    }
    
    private func getConsistentLocalPosition(snippet: CodeSnippetType, value: DragGesture.Value) -> CGPoint? {
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
    
    private func getConsistentGlobalPosition(snippet: CodeSnippetType, value: DragGesture.Value) -> CGPoint? {
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
