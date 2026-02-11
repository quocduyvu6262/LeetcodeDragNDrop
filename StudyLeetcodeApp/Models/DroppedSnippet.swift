//
//  DroppedSnippet.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/8/25.
//

import Foundation
import SwiftData

@Model
class DroppedSnippet: Hashable {
  var snippet: CodeSnippetType

  var positionX: Double
  var positionY: Double

  var position: CGPoint {
    get { CGPoint(x: positionX, y: positionY) }
    set {
      positionX = newValue.x
      positionY = newValue.y
    }
  }

  init(snippet: CodeSnippetType, position: CGPoint) {
    self.snippet = snippet
    positionX = position.x
    positionY = position.y
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(snippet)
    hasher.combine(positionX)
    hasher.combine(positionY)
  }

  static func == (lhs: DroppedSnippet, rhs: DroppedSnippet) -> Bool {
    lhs.snippet == rhs.snippet && lhs.positionX == rhs.positionX && lhs.positionY == rhs.positionY
  }
}
