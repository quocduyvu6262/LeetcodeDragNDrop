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
    var snippetId: String
    var snippetText: String
    var x: Double
    var y: Double
    var problemName: String
    
    init(snippetId: String, snippetText: String, x: Double, y: Double, problemName: String) {
        self.snippetId = snippetId
        self.snippetText = snippetText
        self.x = x
        self.y = y
        self.problemName = problemName
    }
}
