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
    let availableSnippets: [String]
    @Binding var currentSnippet: String
    @ObservedObject var coordinator: DragDropCoordinator

    let onDrop: (String) -> Void
    let onDragToCanvas: (String, CGPoint) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0
    @State private var snippetPositions: [String: CGRect] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
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
                                DragGesture(minimumDistance: 0, coordinateSpace: .named("solutionView"))
                                    .onChanged { value in
                                        if !coordinator.isDragging {
                                            coordinator.startDrag(snippet: snippet, source: .snippetList)
                                        }
                                        //TODO: Get snippet global position relative to SolutionView
                                        if let snippetFrame = snippetPositions[snippet] {
                                            let globalPosition = CGPoint(
                                                x: snippetFrame.midX + value.translation.width - 10,
                                                y: snippetFrame.midY + value.translation.height
                                            )
                                            coordinator.updateDragPosition(globalPosition)
                                        }
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
                .padding(10)
            }
            .frame(width: UIScreen.main.bounds.width - 20)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(true ? Color.blue : Color.primary.opacity(1.0), lineWidth: 2)
            }
            .coordinateSpace(name: "scrollView")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                self.scrollOffset = offset.y
            }
            .onPreferenceChange(SnippetPositionPreferenceKey.self) { positions in
                self.snippetPositions = positions
            }
        }
    }
}
