//
//  SolutionView+Logic.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/4/25.
//

import Foundation
import SwiftData
import SwiftUI

extension SolutionView {
  func reflowSnippets(_ snippets: [DroppedSnippet]) -> [DroppedSnippet] {
    // Sort snippets by y position to process from top to bottom
    var sortedSnippets = snippets.sorted { $0.position.y < $1.position.y }
    let snippetHeight = Constants.snippetHeight
    let snippetSpacing: CGFloat = Constants.snippetSpacing // Additional spacing between snippets

    // Process each snippet starting from the second one
    for i in 1 ..< sortedSnippets.count {
      let currentSnippet = sortedSnippets[i]
      var newY = currentSnippet.position.y

      // Check overlap with all previous snippets
      for j in 0 ..< i {
        let previousSnippet = sortedSnippets[j]

        // Calculate if there's vertical overlap
        let currentTop = newY - snippetHeight / 2
        let previousBottom = previousSnippet.position.y + snippetHeight / 2

        if currentTop < previousBottom {
          // Push current snippet down
          newY = previousBottom + snippetHeight / 2 + snippetSpacing
        }
      }

      // Update the position if it changed
      if newY != currentSnippet.position.y {
        sortedSnippets[i] = DroppedSnippet(snippet: currentSnippet.snippet, position: CGPoint(x: currentSnippet.position.x, y: newY))
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
    for droppedSnippet in droppedSnippets {
      modelContext.insert(droppedSnippet)
    }

    // Save changes to SwiftData
    try? modelContext.save()
  }

  func updateDroppedSnippets(droppedSnippet: DroppedSnippet) {
    if let index = droppedSnippets.firstIndex(where: { $0.snippet == droppedSnippet.snippet }) {
      droppedSnippets.remove(at: index)
      if let savedIndex = savedSnippets.firstIndex(where: { $0.snippet == droppedSnippet.snippet }) {
        modelContext.delete(savedSnippets[savedIndex])
      }
    }

    droppedSnippets.append(droppedSnippet)
    modelContext.insert(droppedSnippet)
    try? modelContext.save()

    if let index = availableSnippets.firstIndex(of: droppedSnippet.snippet) {
      availableSnippets.remove(at: index)
    }
  }

  func returnSnippetToAvailable(snippet: CodeSnippetType) {
    if let index = availableSnippets.firstIndex(of: snippet) {
      availableSnippets.remove(at: index)
    }
    availableSnippets.append(snippet)

    if let index = droppedSnippets.firstIndex(where: { $0.snippet.id == snippet.id }) {
      droppedSnippets.remove(at: index)
    }
    
    if let savedIndex = savedSnippets.firstIndex(where: { $0.snippet == snippet }) {
      modelContext.delete(savedSnippets[savedIndex])
      try? modelContext.save()
    }
  }

  func loadDroppedSnippets() {
    let function = problem.function
    droppedSnippets = savedSnippets
    availableSnippets = problem.snippets.filter { snippet in
      !droppedSnippets.contains { $0.snippet == snippet }
    }

    // Default add function def to droppedSnippets
    if !droppedSnippets.contains(where: { $0.snippet.text == function }) {
      let snippetWidth = calculateSnippetWidth(text: function)
      let snippetPosition = CGPoint(x: snippetWidth / 2 + Constants.dotSpacing, y: Constants.snippetHeight * 2)
      let consistentSnippetPosition = consistentDot(to: snippetPosition)
      let functionSnippet = CodeSnippetType(
        id: "\(problem.name)_function",
        problemName: problem.name,
        text: function
      )
      droppedSnippets.append(DroppedSnippet(snippet: functionSnippet, position: consistentSnippetPosition))
    }

    // Add current SnippetSnapshot to SnippetHistory
    if snippetHistory.currentSnapshot == nil {
      snippetHistory.currentSnapshot = SnippetSnapshot(dropped: droppedSnippets)
    }
  }

  func submit() {
    let userCode = buildCodeFromDroppedSnippets(droppedSnippets)
    let fullFunction = problem.function
    let functionName = if let nameMatch = fullFunction.split(separator: " ").dropFirst().first?.split(separator: "(").first {
      String(nameMatch)
    } else {
      "user_function" // fallback
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
//        print(wrappedCode)
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
    for droppedSnippet in snapshot.dropped {
      updateDroppedSnippets(droppedSnippet: droppedSnippet)
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

extension SolutionView {
  func dropOnCanvas(snippet: CodeSnippetType, position: CGPoint) {
    // Update SwiftData
    updateDroppedSnippets(droppedSnippet: DroppedSnippet(snippet: snippet, position: position))

    // Update dropped snippets with reflowing
    let reflowedSnippets = reflowSnippets(droppedSnippets)
    droppedSnippets = reflowedSnippets

    // Snippet on SnippetHistory
    let currentSnapshot = SnippetSnapshot(dropped: droppedSnippets)
    snippetHistory.push(currentSnapshot)
  }

  func dropOnList(snippet: CodeSnippetType) {
    // Snippet on SwiftData
    returnSnippetToAvailable(snippet: snippet)

    // Snippet on SnippetHistory
    let snapshot = SnippetSnapshot(dropped: droppedSnippets)
    snippetHistory.push(snapshot)
  }
}
