//
//  SolutionView+Helper.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/4/25.
//

import Foundation
import SwiftData

extension SolutionView {
    
    func reflowSnippets(_ snippets: [(snippet: String, position: CGPoint)]) -> [(snippet: String, position: CGPoint)] {
        // Sort snippets by y position to process from top to bottom
        var sortedSnippets = snippets.sorted { $0.position.y < $1.position.y }
        let snippetHeight = Constants.snippetHeight
        let snippetSpacing: CGFloat = Constants.snippetSpacing // Additional spacing between snippets
        
        // Process each snippet starting from the second one
        for i in 1..<sortedSnippets.count {
            let currentSnippet = sortedSnippets[i]
            var newY = currentSnippet.position.y
            
            // Check overlap with all previous snippets
            for j in 0..<i {
                let previousSnippet = sortedSnippets[j]
                
                // Calculate if there's vertical overlap
                let currentTop = newY - snippetHeight/2
                let previousBottom = previousSnippet.position.y + snippetHeight/2
                
                if currentTop < previousBottom {
                    // Push current snippet down
                    newY = previousBottom + snippetHeight/2 + snippetSpacing
                }
            }
            
            // Update the position if it changed
            if newY != currentSnippet.position.y {
                sortedSnippets[i] = (currentSnippet.snippet, CGPoint(x: currentSnippet.position.x, y: newY))
            }
        }
        
        // Update SwiftData with the new positions
        droppedSnippets = sortedSnippets
        updateAllDroppedSnippets()
        return sortedSnippets
    }
    
    func updateAllDroppedSnippets() {
        // First, delete all existing snippets for this problem
        for savedSnippet in savedSnippets {
            modelContext.delete(savedSnippet)
        }
        
        // Then insert all current dropped snippets with their new positions
        for (snippet, position) in droppedSnippets {
            let newSnippet = DroppedSnippet(
                snippetText: snippet,
                x: position.x,
                y: position.y,
                problemName: problem.name
            )
            modelContext.insert(newSnippet)
        }
        
        // Save changes to SwiftData
        try? modelContext.save()
    }
    
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
        let function = problem.function
        droppedSnippets = savedSnippets.map { (snippet: $0.snippetText, position: CGPoint(x: $0.x, y: $0.y)) }
        availableSnippets = problem.snippets.filter { snippet in
            !droppedSnippets.contains { $0.snippet == snippet }
        }
        
        // Default add function def to droppedSnippets
        if !droppedSnippets.contains(where: { $0.snippet == function }) {
            let snippetWidth = calculateSnippetWidth(text: function)
            let snippetPosition = CGPoint(x: snippetWidth / 2 + Constants.dotSpacing, y: Constants.snippetHeight * 2)
            let consistentSnippetPosition = consistentDot(to: snippetPosition)
            droppedSnippets.append((function, consistentSnippetPosition))
        }
        
        // Add current SnippetSnapshot to SnippetHistory
        if snippetHistory.currentSnapshot == nil {
            snippetHistory.currentSnapshot = SnippetSnapshot(dropped: droppedSnippets)
        }
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
\(userCode)

result = \(functionName)(\(args))

assert result == \(expectedOutput)
"""
        print(wrappedCode)
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
        if let current = snippetHistory.undo() {
            restoreFrom(snapshot: current)
        }
    }

    func redo() {
        if let next = snippetHistory.redo() {
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
