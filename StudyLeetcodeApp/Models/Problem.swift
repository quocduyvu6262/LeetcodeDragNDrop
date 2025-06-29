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
    let snippets: [CodeSnippetType]
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let problemName = try container.decode(String.self, forKey: .name)
        
        name = try container.decode(String.self, forKey: .name)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        description = try container.decode(String.self, forKey: .description)
        // Convert string array to CodeSnippetType array
        let snippetStrings = try container.decode([String].self, forKey: .snippets)
        snippets = snippetStrings.enumerated().map { index, text in
            // Create a consistent ID using problem name and index
            let consistentId = "\(problemName)_snippet_\(index)"
            return CodeSnippetType(id: consistentId, text: text)
        }
        function = try container.decode(String.self, forKey: .function)
        inputs = try container.decode([String].self, forKey: .inputs)
        outputs = try container.decode([String].self, forKey: .outputs)
        timeComplexityOptions = try container.decode([String].self, forKey: .timeComplexityOptions)
        spaceComplexityOptions = try container.decode([String].self, forKey: .spaceComplexityOptions)
        correctTimeComplexity = try container.decode(String.self, forKey: .correctTimeComplexity)
        correctSpaceComplexity = try container.decode(String.self, forKey: .correctSpaceComplexity)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(description, forKey: .description)
        // Convert CodeSnippetType array back to string array
        let snippetStrings = snippets.map { $0.text }
        try container.encode(snippetStrings, forKey: .snippets)
        try container.encode(function, forKey: .function)
        try container.encode(inputs, forKey: .inputs)
        try container.encode(outputs, forKey: .outputs)
        try container.encode(timeComplexityOptions, forKey: .timeComplexityOptions)
        try container.encode(spaceComplexityOptions, forKey: .spaceComplexityOptions)
        try container.encode(correctTimeComplexity, forKey: .correctTimeComplexity)
        try container.encode(correctSpaceComplexity, forKey: .correctSpaceComplexity)
    }
}
