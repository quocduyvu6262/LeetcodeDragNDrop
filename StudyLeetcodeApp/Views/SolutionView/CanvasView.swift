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
    @Binding var currentSnippet: String

    private let dotSpacing: CGFloat = Constants.dotSpacing
    @State private var highlightedDot: CGPoint?
    @State private var canvasHeight: CGFloat = 0
    @State private var draggedSnippetWidth: CGFloat = 0
    @State private var dragOffset: CGSize = .zero
    @State private var scrollOffset: CGFloat = 0
    
    // Add coordinate space name
    private let canvasCoordinateSpace = "canvas"
    
    let onDrop: (String, CGPoint) -> Void
    let onDragToList: (String) -> Void

    // Add computed property for sorted snippets
    private var sortedDroppedSnippets: [(snippet: String, position: CGPoint)] {
        droppedSnippets.sorted { $0.position.y < $1.position.y }
    }

    init(minCanvasHeight: CGFloat, 
         droppedSnippets: [(String, CGPoint)],
         currentSnippet: Binding<String>,
         onDrop: @escaping (String, CGPoint) -> Void,
         onDragToList: @escaping (String) -> Void
    ) {
        self.minCanvasHeight = minCanvasHeight
        self._canvasHeight = State(initialValue: minCanvasHeight)
        self._currentSnippet = currentSnippet
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
                            .offset(currentSnippet == snippet.snippet ? dragOffset : .zero)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        currentSnippet = snippet.snippet
                                        dragOffset = value.translation
                                        
                                        // Convert local position to global position
                                        let localPosition = CGPoint(
                                            x: snippet.position.x + value.translation.width,
                                            y: snippet.position.y + value.translation.height
                                        )
                                        // Calculate the global position
                                        let globalPosition = CGPoint(
                                            x: localPosition.x,
                                            y: localPosition.y + self.scrollOffset
                                        )
                                        
                                        let listViewY = (self.minCanvasHeight / Constants.minCanvasHeightFactor) * Constants.canvasHeightFactor
                                        highlightedDot = nearestDot(to: localPosition, in: geometry.size)
                                        updateCanvasHeight(for: localPosition)
                                    }
                                    .onEnded { value in
                                        if let dot = highlightedDot {
                                            onDrop(snippet.snippet, dot)
                                        }
                                        dragOffset = .zero
                                        highlightedDot = nil
                                    }
                            )
                    }
                    
                    // Highlighted drop zone
                    if let dot = highlightedDot {
                        if isSnippetInBounds(for: currentSnippet, at: dot) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: calculateSnippetWidth(text: currentSnippet), height: Constants.snippetHeight)
                                .cornerRadius(8)
                                .position(dot)
                        } else {
                            Rectangle()
                                .fill(Color.red.opacity(0.3))
                                .frame(width: calculateSnippetWidth(text: currentSnippet), height: Constants.snippetHeight)
                                .cornerRadius(8)
                                .position(dot)
                        }
                    }
                }
                .frame(width: geometry.size.width, height: max(minCanvasHeight, canvasHeight))
                .background(Color.clear.contentShape(Rectangle()))
                .clipped()
                .onAppear {
                    canvasHeight = max(canvasHeight, minCanvasHeight)
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
    
    func updateCanvasHeight(for point: CGPoint) {
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
}

struct CanvasDropDelegate: DropDelegate {
    @Binding var highlightedDot: CGPoint?
    @Binding var currentSnippet: String
    
    let droppedSnippets: [(String, CGPoint)]
    let canvasSize: CGSize
    let canvasHeight: CGFloat
    let updateHeight: (CGPoint) -> Void
    let onDrop: (String, CGPoint) -> Void
    
    let snippetHeight: CGFloat = Constants.snippetHeight
    let dotSpacing: CGFloat = Constants.dotSpacing
    
    private var sortedDroppedSnippets: [(String, CGPoint)] {
        droppedSnippets.sorted { $0.1.y < $1.1.y }
    }
    
    
    func dropEntered(info: DropInfo) {
        let fingerLocation = info.location
        
        // Find the nearest grid dot
        self.highlightedDot = self.nearestDot(to: fingerLocation, in: canvasSize)
        self.updateHeight(fingerLocation)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let fingerLocation = info.location
        
        // Update highlighted dot and insertion index
        self.highlightedDot = self.nearestDot(to: fingerLocation, in: canvasSize)
        
        self.updateHeight(fingerLocation)
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        highlightedDot = nil
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let dot = highlightedDot,
              let itemProvider = info.itemProviders(for: [.text]).first else {
            highlightedDot = nil
            return false
        }
        
        if !isSnippetInBounds(for: currentSnippet, at: dot) {
            highlightedDot = nil
            return false
        }
        
        itemProvider.loadObject(ofClass: NSString.self) { (object, error) in
            if let snippet = object as? String {
                DispatchQueue.main.async {
                    onDrop(snippet, dot)
                }
            }
        }
        
        highlightedDot = nil
        return true
    }
    
    private func nearestDot(to location: CGPoint, in size: CGSize) -> CGPoint? {
        let x = round(location.x / dotSpacing) * dotSpacing
        let y = round(location.y / dotSpacing) * dotSpacing
        
        return CGPoint(
            x: max(0, min(x, size.width - dotSpacing)),
            y: max(0, min(y, canvasHeight - dotSpacing))
        )
    }
}

#Preview {
    // Sample state for the preview
    @State var currentSnippet = "hashmap = {}"
    @State var droppedSnippets: [(snippet: String, position: CGPoint)] = [
        ("for num in array:", CGPoint(x: 20, y: 20)),
        ("if target - num in hashmap:", CGPoint(x: 20, y: 60))
    ]
    
    // Define the onDrop closure for the preview
    let onDrop: (String, CGPoint) -> Void = { snippet, position in
        print("Dropped \(snippet) at \(position)")
    }
    
    CanvasView(
        minCanvasHeight: 300, // Minimum height for the canvas
        droppedSnippets: droppedSnippets,
        currentSnippet: $currentSnippet,
        onDrop: onDrop,
        onDragToList: { snippet in
            print("Dragged \(snippet) to list")
        }
    )
}
