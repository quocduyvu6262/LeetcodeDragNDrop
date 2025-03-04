//
//  SolutionView+Helper.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/4/25.
//

import Foundation

extension SolutionView {
    func checkSnippetsCorrectness() -> (orderCorrect: Bool, indentCorrect: Bool) {
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
}
