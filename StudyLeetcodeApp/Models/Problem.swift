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
    let function: String
    let inputs: [String]
    let outputs: [String]
    let timeComplexityOptions: [String]
    let spaceComplexityOptions: [String]
    let correctTimeComplexity: String
    let correctSpaceComplexity: String
    
    enum CodingKeys: String, CodingKey {
        case name, difficulty, description, snippets, function, inputs, outputs
        case timeComplexityOptions = "time_complexity_options"
        case spaceComplexityOptions = "space_complexity_options"
        case correctTimeComplexity = "correct_time_complexity"
        case correctSpaceComplexity = "correct_space_complexity"
    }
}
