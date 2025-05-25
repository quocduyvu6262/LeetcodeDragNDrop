//
//  DragDropCoordinator.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/19/25.
//

import Foundation
import SwiftUI

class DragDropCoordinator: ObservableObject {
    @Published var isDragging = false
    @Published var currentSnippet: String = ""
    @Published var dragPosition: CGPoint?
    @Published var dragSource: DragSource = .none
    @Published var isOverCanvas = false
    @Published var isOverSnippetList = false
    
    enum DragSource {
        case canvas
        case snippetList
        case none
    }
    
    func startDrag(snippet: String, source: DragSource) {
        currentSnippet = snippet
        isDragging = true
        dragSource = source
        switch source {
        case .canvas:
            isOverCanvas = true
        case .snippetList:
            isOverSnippetList = true
        case .none:
            break
        }
    }
    
    func updateDragPosition(_ position: CGPoint) {
        dragPosition = position
    }
    
    func endDrag() {
        isDragging = false
        currentSnippet = ""
        dragPosition = nil
        dragSource = .none
        isOverCanvas = false
        isOverSnippetList = false
    }
}

