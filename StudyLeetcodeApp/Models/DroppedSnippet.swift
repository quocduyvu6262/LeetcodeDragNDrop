//
//  DroppedSnippet.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/8/25.
//

import Foundation
import SwiftData

@Model
class DroppedSnippet {
    var snippet: CodeSnippetType
    var x: Double
    var y: Double
    var problemName: String
    
    init(snippet: CodeSnippetType, x: Double, y: Double, problemName: String) {
        self.snippet = snippet
        self.x = x
        self.y = y
        self.problemName = problemName
    }
}
