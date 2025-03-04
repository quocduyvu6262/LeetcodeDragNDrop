//
//  DataManager.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import Foundation

class DataManager {
    static func loadProblems() -> [Category] {
        guard let url = Bundle.main.url(forResource: "problems", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load JSON")
            return []
        }
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode([Category].self, from: data)
            return result
        } catch {
            print("Decoding error: \(error)")
            return []
        }
    }
}
