//
//  CodeSnippet.swift
//  StudyLeetcodeApp
//
//  Created by Tony Vu on 6/28/25.
//

import Foundation

struct CodeSnippetType: Codable, Identifiable, Equatable, Hashable {
    var id: String
    let text: String
}
