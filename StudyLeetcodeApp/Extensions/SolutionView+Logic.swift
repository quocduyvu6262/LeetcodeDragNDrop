//
//  SolutionView+Helper.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/4/25.
//

import Foundation
import SwiftData

extension SolutionView {
    func isSnippetsCorrect() -> (orderCorrect: Bool, indentCorrect: Bool) {
        // Check Order
        let sortedDroppedSnippets = droppedSnippets.sorted { $0.position.y < $1.position.y }
        let droppedSnippetTexts = sortedDroppedSnippets.map { $0.snippet }
        let correctSnippetTexts = problem.correctOrder.map { problem.snippets[$0] }
        let isOrderCorrect = droppedSnippetTexts == correctSnippetTexts
        
        // Check Indentation
        var isIndentCorrect = true
        var firstIndent: Int = 0
        if sortedDroppedSnippets.count == problem.correctIndentation.count {
            for (index, droppedSnippet) in sortedDroppedSnippets.enumerated() {
                let snippetWidth = calculateSnippetWidth(text: droppedSnippet.snippet)
                let leftPosition = droppedSnippet.position.x - snippetWidth / 2
                
                if index == 0 {
                    firstIndent = Int(leftPosition / Constants.dotSpacing) - 1
                }
                
                let currentStep = Int(leftPosition / Constants.dotSpacing) - (1 + firstIndent)
                let correctStep = problem.correctIndentation[index]
                
                if currentStep != correctStep {
                    isIndentCorrect = false
                    break
                }
            }
        }
        
        return (isOrderCorrect, isIndentCorrect)
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
        droppedSnippets = savedSnippets.map { (snippet: $0.snippetText, position: CGPoint(x: $0.x, y: $0.y)) }
        availableSnippets = problem.snippets.filter { snippet in
            !droppedSnippets.contains { $0.snippet == snippet }
        }
    }
    
}
