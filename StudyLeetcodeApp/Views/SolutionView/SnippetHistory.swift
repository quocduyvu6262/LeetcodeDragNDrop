//
//  SnippetHistory.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/5/25.
//

import Foundation

struct SnippetSnapshot {
    let dropped: [(String, CGPoint)]
}

class SnippetHistory: ObservableObject {
    private(set) var undoStack: [SnippetSnapshot] = []
    private(set) var redoStack: [SnippetSnapshot] = []

    func push(_ snapshot: SnippetSnapshot) {
        undoStack.append(snapshot)
        redoStack.removeAll()
    }

    func undo(current: SnippetSnapshot) -> SnippetSnapshot? {
        guard let last = undoStack.popLast() else { return nil }
        redoStack.append(current)
        return last
    }

    func redo(current: SnippetSnapshot) -> SnippetSnapshot? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(current)
        return next
    }

    func reset() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}

