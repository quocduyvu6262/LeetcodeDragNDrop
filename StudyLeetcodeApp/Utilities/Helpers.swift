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
    let padding: CGFloat = 16
    return ceil(size.width) + padding
}

func calculateSnippetWidth(text: String, font: UIFont = Constants.snippetFont) -> CGFloat {
    let textWidth = calculateTextWidth(text: text)
    let numberOfDotSpacing = round(textWidth / Constants.dotSpacing)
    let evenNumberOfDotSpacing = numberOfDotSpacing.truncatingRemainder(dividingBy: 2) == 0 ? numberOfDotSpacing : numberOfDotSpacing + 1
    let width = evenNumberOfDotSpacing * Constants.dotSpacing
    return width
}

func isDroppable(for text: String, at location: CGPoint, with droppedSnippets: [(String, CGPoint)] = []) -> Bool {
    let x = location.x
    let y = location.y
    
    // Check edge
    let snippetWidth = calculateSnippetWidth(text: text)
    let remainingWidth = x - snippetWidth / 2
    let edgeAvailable = remainingWidth >= Constants.dotSpacing
    guard edgeAvailable else { return false }
    
    // Check overlap
    let newSnippetHeight: CGFloat = Constants.snippetHeight
    let newLeft = x - snippetWidth / 2
    let newRight = x + snippetWidth / 2
    let newTop = y - newSnippetHeight / 2
    let newBottom = y + newSnippetHeight / 2
    
    for (snippetText, snippetLocation) in droppedSnippets {
        if snippetText == text { continue }
        let existingWidth = calculateSnippetWidth(text: snippetText)
        let existingHeight: CGFloat = Constants.snippetHeight
        
        let existingLeft = snippetLocation.x - existingWidth / 2
        let existingRight = snippetLocation.x + existingWidth / 2
        let existingTop = snippetLocation.y - existingHeight / 2
        let existingBottom = snippetLocation.y + existingHeight / 2
        
        // Check if rectangles overlap
        let horizontalOverlap = newLeft < existingRight && newRight > existingLeft
        let verticalOverlap = newTop < existingBottom && newBottom > existingTop
        
        if horizontalOverlap && verticalOverlap {
            return false
        }
    }
    
    
    return true
}
