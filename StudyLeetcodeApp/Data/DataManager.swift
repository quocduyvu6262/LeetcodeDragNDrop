//
//  DataManager.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import Foundation

class DataManager {

    private static let problemsKey = "cached_problems"

    static func loadProblems() -> [Category] {
        guard let url = Bundle.main.url(forResource: "problems", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load JSON")
            return []
        }
        do {
            let decoder = JSONDecoder()
            var result = try decoder.decode([Category].self, from: data)
            for index in 0..<result.count {
                if let cachedProblems = loadProblems(for: result[index].name) {
                    result[index].problems = cachedProblems
                }
            }
            return result
        } catch {
            print("Decoding error: \(error)")
            return []
        }
    }

    static func saveProblems(_ problems: [Problem], for category: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(problems) {
            UserDefaults.standard.set(encoded, forKey: problemsKey + category)
        }
    }

    static func loadProblems(for category: String) -> [Problem]? {
        if let savedData = UserDefaults.standard.data(forKey: problemsKey + category) {
            let decoder = JSONDecoder()
            return try? decoder.decode([Problem].self, from: savedData)
        }
        return nil
    }
}
