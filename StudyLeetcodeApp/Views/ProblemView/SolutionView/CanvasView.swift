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
    
    let onDrop: (String, CGPoint) -> Void

    
    init(minCanvasHeight: CGFloat, 
         droppedSnippets: [(String, CGPoint)],
         currentSnippet: Binding<String>,
         onDrop: @escaping (String, CGPoint) -> Void
    ) {
        self.minCanvasHeight = minCanvasHeight
        self._canvasHeight = State(initialValue: minCanvasHeight)
        self._currentSnippet = currentSnippet
        self.droppedSnippets = droppedSnippets
        self.onDrop = onDrop
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    // Grid of dots
                    ForEach(0..<Int(canvasHeight / dotSpacing), id: \.self) { row in
                        ForEach(0..<Int(geometry.size.width / dotSpacing), id: \.self) { col in
                            Circle()
                                .frame(width: 3, height: 3)
                                .opacity(0.25)
                                .foregroundColor(highlightedDot == CGPoint(x: CGFloat(col) * dotSpacing, y: CGFloat(row) * dotSpacing) ? .blue : .gray)
                                .position(x: CGFloat(col) * dotSpacing, y: CGFloat(row) * dotSpacing)
                        }
                        
                    }
                    
                    // Display dropped snippets
                    ForEach(droppedSnippets.indices, id: \.self) { index in
                        let snippet = droppedSnippets[index]
                        CodeSnippet(code: snippet.snippet)
                            .position(snippet.position)
                            .onDrag {
                                currentSnippet = snippet.0
                                let dragItem = NSItemProvider(object: snippet.0 as NSString)
                                return dragItem
                            }
                    }
                    
                    // Highlighted drop zone
                    if let dot = highlightedDot {
                        if isDroppable(for: currentSnippet, at: dot, with: droppedSnippets) {
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
                .background(Color.white)
                .clipped()
                .onDrop(of: [.text], delegate: CanvasDropDelegate(
                    highlightedDot: $highlightedDot,
                    currentSnippet: $currentSnippet,
                    droppedSnippets: droppedSnippets,
                    canvasSize: geometry.size,
                    canvasHeight: canvasHeight,
                    updateHeight: updateCanvasHeight,
                    onDrop: onDrop
                ))
            }
            .clipped()
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color.black.opacity(1.0), lineWidth: 2)
            }
        }
    }
    
    func updateCanvasHeight(for point: CGPoint) {
        let requiredHeight = point.y + 100 // Add buffer for snippet height
        if requiredHeight > canvasHeight {
            canvasHeight = requiredHeight
        }
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
    
    func dropEntered(info: DropInfo) {
        let fingerLocation = info.location
        let snippetWidth = calculateSnippetWidth(text: currentSnippet)
        let snippetCenter = CGPoint(
            x: fingerLocation.x - snippetWidth / 3,
            y: fingerLocation.y - snippetHeight / 3
        )
        self.highlightedDot = self.nearestDot(to: snippetCenter)
        if self.highlightedDot == nil { return }
        self.updateHeight(snippetCenter)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let fingerLocation = info.location
        let snippetWidth = calculateSnippetWidth(text: currentSnippet)
        let snippetCenter = CGPoint(
            x: fingerLocation.x - snippetWidth / 3,
            y: fingerLocation.y - snippetHeight / 3
        )
        self.highlightedDot = self.nearestDot(to: snippetCenter)
        if self.highlightedDot == nil { return nil }
        self.updateHeight(snippetCenter)
        
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
        
        if !isDroppable(for: currentSnippet, at: dot, with: droppedSnippets) {
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
    
    private func nearestDot(to location: CGPoint) -> CGPoint? {
        let x = round(location.x / dotSpacing) * dotSpacing
        let y = round(location.y / dotSpacing) * dotSpacing
        
        return CGPoint(
            x: max(0, min(x, canvasSize.width - dotSpacing)),
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
        droppedSnippets.append((snippet, position))
        print("Dropped \(snippet) at \(position)")
    }
    
    return CanvasView(
        minCanvasHeight: 300, // Minimum height for the canvas
        droppedSnippets: droppedSnippets,
        currentSnippet: $currentSnippet,
        onDrop: onDrop
    )
}
