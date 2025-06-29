//
//  SnippetHistory.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/5/25.
//

import Foundation

struct SnippetSnapshot {
    let dropped: [(CodeSnippetType, CGPoint)]
}

class SnippetHistory: ObservableObject {
    var currentSnapshot: SnippetSnapshot?
    private(set) var undoStack: [SnippetSnapshot] = []
    private(set) var redoStack: [SnippetSnapshot] = []

    func push(_ newSnapshot: SnippetSnapshot) {
        if let currentSnapshot = self.currentSnapshot {
            undoStack.append(currentSnapshot)
            redoStack.removeAll()
            self.currentSnapshot = newSnapshot
        }
    }

    /**
     Push currentSnapshot to redoStack and make prev a currentSnapshot state
     Return an optional currentSnapshot
     */
    func undo() -> SnippetSnapshot? {
        guard !undoStack.isEmpty else { return nil }
        let prev = undoStack.popLast()
        if let currentSnapshot = self.currentSnapshot {
            redoStack.append(currentSnapshot)
            self.currentSnapshot = prev
            return self.currentSnapshot
        }
        return nil
    }

    /**
     Push currentSnapshot to undoStack and make next snapshot a currentSnapshot state
     Return an optional currentSnapshot
     */
    func redo() -> SnippetSnapshot? {
        guard !redoStack.isEmpty else { return nil }
        let next = redoStack.popLast()
        if let currentSnapshot = self.currentSnapshot {
            undoStack.append(currentSnapshot)
            self.currentSnapshot = next
            return self.currentSnapshot
        }
        return nil
    }

    func reset() {
        undoStack.removeAll()
        redoStack.removeAll()
        self.currentSnapshot = SnippetSnapshot.init(dropped: [])
    }
}

