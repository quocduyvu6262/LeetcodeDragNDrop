//
//  Problem.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import Foundation

struct Problem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let difficulty: String
    let description: String
    let snippets: [String]
    let correctOrder: [Int]
    let correctIndentation: [Int]
    let complexityOptions: [String]
    let correctComplexity: Int
    
    enum CodingKeys: String, CodingKey {
        case name, difficulty, description, snippets
        case correctOrder = "correct_order"
        case correctIndentation = "correct_indentation"
        case complexityOptions = "complexity_options"
        case correctComplexity = "correct_complexity"
    }
}
