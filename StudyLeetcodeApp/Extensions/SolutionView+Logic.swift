//
//  SolutionView+Helper.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/4/25.
//

import Foundation
import SwiftData

extension SolutionView {
    
    func updateDroppedSnippets(snippet: String, position: CGPoint) {
        if let index = droppedSnippets.firstIndex(where: { $0.snippet == snippet }) {
            droppedSnippets.remove(at: index)
            if let savedIndex = savedSnippets.firstIndex(where: { $0.snippetText == snippet }) {
                modelContext.delete(savedSnippets[savedIndex])
            }
        }
        
        droppedSnippets.append((snippet, position))
        let newSnippet = DroppedSnippet(
            snippetText: snippet,
            x: position.x,
            y: position.y,
            problemName: problem.name
        )
        modelContext.insert(newSnippet)
        
        
        try? modelContext.save()
        if let index = availableSnippets.firstIndex(of: snippet) {
            availableSnippets.remove(at: index)
        }
    }
    
    func returnSnippetToAvailable(snippet: String) {
        if let index = availableSnippets.firstIndex(of: snippet) {
            availableSnippets.remove(at: index)
        }
        availableSnippets.append(snippet)
        
        if let index = droppedSnippets.firstIndex(where: {$0.snippet == snippet} ) {
            droppedSnippets.remove(at: index)
            if let savedIndex = savedSnippets.firstIndex(where: {$0.snippetText == snippet}) {
                modelContext.delete(savedSnippets[savedIndex])
                try? modelContext.save()
            }
        }
    }
    
    func loadDroppedSnippets() {
        droppedSnippets = savedSnippets.map { (snippet: $0.snippetText, position: CGPoint(x: $0.x, y: $0.y)) }
        availableSnippets = problem.snippets.filter { snippet in
            !droppedSnippets.contains { $0.snippet == snippet }
        }
    }
    
    func buildWrappedCode(code: String) -> String {
        let wrappedCode =
"""
def user_function(array, target):
\(code)

array = [2, 7, 11, 15]
target = 9
result = user_function(array, target)
assert result == [7, 2]
"""
        return wrappedCode
    }
    
    func submit() {
        let userCode = buildCodeFromDroppedSnippets(droppedSnippets)
        let fullFunction = problem.function
        let functionName: String
        if let nameMatch = fullFunction.split(separator: " ").dropFirst().first?.split(separator: "(").first {
            functionName = String(nameMatch)
        } else {
            functionName = "user_function" // fallback
        }
        let inputs = problem.inputs[0]
        let expectedOutput = problem.outputs[0]
        
        let args = inputs
        
        let wrappedCode =
"""
\(fullFunction)
\(userCode)

result = \(functionName)(\(args))

assert result == \(expectedOutput)
"""
        
        DispatchQueue.main.async {
            pythonExecutorCode = wrappedCode
            runPython = true
        }
    }
    
    func restoreFrom(snapshot: SnippetSnapshot) {
        // Clear all current dropped snippets
        for snippet in droppedSnippets {
            returnSnippetToAvailable(snippet: snippet.snippet)
        }

        // Restore from snapshot
        for (snippet, position) in snapshot.dropped {
            updateDroppedSnippets(snippet: snippet, position: position)
        }
    }

    
    func undo() {
        let current = SnippetSnapshot(dropped: droppedSnippets)
        if let previous = snippetHistory.undo(current: current) {
            restoreFrom(snapshot: previous)
        }
    }

    func redo() {
        let current = SnippetSnapshot(dropped: droppedSnippets)
        if let next = snippetHistory.redo(current: current) {
            restoreFrom(snapshot: next)
        }
    }

    
    func resetAll() {
        for snippet in droppedSnippets {
            returnSnippetToAvailable(snippet: snippet.snippet)
        }
        droppedSnippets.removeAll()
        snippetHistory.reset()
    }
    
}
