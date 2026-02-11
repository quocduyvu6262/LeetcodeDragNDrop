//
//  CodeSnippetType.swift
//  StudyLeetcodeApp
//
//  Created by Tony Vu on 6/28/25.
//

import Foundation
import SwiftData

@Model
class CodeSnippetType: Hashable {
  var id: String
  var problemName: String
  var text: String

  init(id: String, problemName: String, text: String) {
    self.id = id
    self.problemName = problemName
    self.text = text
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(problemName)
    hasher.combine(text)
  }

  static func == (lhs: CodeSnippetType, rhs: CodeSnippetType) -> Bool {
    lhs.id == rhs.id && lhs.problemName == rhs.problemName
  }
}
