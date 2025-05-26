//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { current, _ in current }
    }
}

struct SnippetsListView: View {
    // Parameters
    let availableSnippets: [String]
    @ObservedObject var coordinator: DragDropCoordinator
    @Binding var highlightedDot: CGPoint?
    
    // Variables
    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var dragOffset: CGSize = .zero
    @State private var snippetPositions: [String: CGRect] = [:]
    @State private var isScrolling = false
    @State private var scrollEndTimer: Timer?
    
    // Closure
    let onDrop: (String) -> Void
    let onDragToCanvas: (String, CGPoint) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.vertical], showsIndicators: true) {
                FlowLayout {
                    ScrollViewOffsetTracker()
                    ForEach(availableSnippets, id: \.self) { snippet in
                        CodeSnippet(code: snippet)
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
                                        if let snippetFrame = snippetPositions[snippet] {
                                            let globalPosition = CGPoint(
                                                x: snippetFrame.midX + value.translation.width - 10,
                                                y: snippetFrame.midY + value.translation.height
                                            )
                                            /**
                                             Drag on Canvas and SnippetList. Especially when dragging on Canvas, the onChange() also used coordinator.updateDragPosition with consistent dot so that the snippet stays consistent with highlighted dot.
                                             */
                                            coordinator.updateDragPosition(globalPosition)
                                        }
                                    }
                                    .onEnded { value in
                                        if coordinator.isOverCanvas, let dot = highlightedDot {
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
    
    private func consistentDot(to location: CGPoint) -> CGPoint? {
        let x = round(location.x / dotSpacing) * dotSpacing
        let y = round(location.y / dotSpacing) * dotSpacing
        
        return CGPoint(
            x: max(0, x),
            y: max(0, y)
        )
    }
}
