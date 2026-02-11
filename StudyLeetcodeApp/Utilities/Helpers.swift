//
//  Helpers.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import Foundation
import SwiftUI

func calculateTextWidth(text: String, font: UIFont = Constants.snippetFont) -> CGFloat {
  let attributes: [NSAttributedString.Key: Any] = [.font: font]
  let size = (text as NSString).size(withAttributes: attributes)
  let padding: CGFloat = 8
  return floor(size.width) + padding
}

func calculateSnippetWidth(text: String, font _: UIFont = Constants.snippetFont) -> CGFloat {
  let lines = text.components(separatedBy: .newlines)
  var maxWidth: CGFloat = 0.0

  // Calculate the width for each line and find the maximum
  for line in lines {
    let lineTextWidth = calculateTextWidth(text: line)
    maxWidth = max(maxWidth, lineTextWidth)
  }

  // Apply your original logic to the maximum width found
  let numberOfDotSpacing = ceil(maxWidth / Constants.dotSpacing)
  let evenNumberOfDotSpacing = numberOfDotSpacing.truncatingRemainder(dividingBy: 2) == 0 ? numberOfDotSpacing : numberOfDotSpacing + 1
  let width = evenNumberOfDotSpacing * Constants.dotSpacing
  return width
}

func isSnippetInBounds(for snippet: CodeSnippetType, at location: CGPoint) -> Bool {
  let text = snippet.text
  let snippetWidth = calculateSnippetWidth(text: text)
  let snippetHeight = Constants.snippetHeight

  // Calculate snippet boundaries
  let leftEdge = location.x - snippetWidth / 2
  let topEdge = location.y - snippetHeight / 2

  // Check boundaries
  let isLeftInBounds = leftEdge >= Constants.dotSpacing
  let isTopInBounds = topEdge >= 0

  return isLeftInBounds && isTopInBounds
}

func buildCodeFromDroppedSnippets(_ snippets: [DroppedSnippet]) -> String {
  let sorted = snippets.sorted(by: { $0.position.y < $1.position.y })

  return sorted.map { droppedSnippet in
    let snippet = droppedSnippet.snippet
    let position = droppedSnippet.position

    let snippetWidth = calculateSnippetWidth(text: snippet.text)
    let leftPosition = position.x - snippetWidth / 2
    let indentLevel = Int(ceil(leftPosition / Constants.dotSpacing))
    if snippet.text.hasPrefix("def ") { // no indent for function declaration
      return snippet.text
    }

    // Handle multi-line snippets by indenting each line
    let lines = snippet.text.split(separator: "\n")
    return lines.map { line in
      let indentation = line.prefix(while: { $0 == " " })
      let lineContent = line.dropFirst(indentation.count)
      let resultIndent = String(repeating: " ", count: indentLevel + indentation.count)
      return resultIndent + lineContent
    }.joined(separator: "\n")

  }.joined(separator: "\n")
}

func consistentDot(to location: CGPoint) -> CGPoint {
  let x = round(location.x / Constants.dotSpacing) * Constants.dotSpacing
  let y = round(location.y / Constants.dotSpacing) * Constants.dotSpacing

  return CGPoint(
    x: max(0, x),
    y: max(0, y)
  )
}

extension String {
  func indented(by spaces: Int) -> String {
    let prefix = String(repeating: " ", count: spaces)
    return split(separator: "\n").map { prefix + $0 }.joined(separator: "\n")
  }
}
