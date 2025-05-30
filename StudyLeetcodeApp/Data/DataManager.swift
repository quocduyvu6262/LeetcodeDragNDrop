//
//  DataManager.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import Foundation

class DataManager {

    private static let problemsKey = "cached_problems"

    static func loadCategories() -> [Category] {
        let fileManager = FileManager.default
        
        guard let categoriesURL = Bundle.main.url(forResource: "ProblemCategories", withExtension: nil) else {
            print("Failed to find ProblemCategories directory")
            return []
        }
        
        var categories: [Category] = []
        
        do {
            // Get all category directories
            let categoryDirectories = try fileManager.contentsOfDirectory(at: categoriesURL, includingPropertiesForKeys: nil)
            
            for categoryURL in categoryDirectories {
                // Skip if not a directory
                guard categoryURL.hasDirectoryPath else { continue }
                
                // Get category name from directory name
                let categoryName = categoryURL.lastPathComponent
                
                // Get all problem JSON files in this category
                let problemFiles = try fileManager.contentsOfDirectory(at: categoryURL, includingPropertiesForKeys: nil)
                    .filter { $0.pathExtension == "json" }
                
                var problems: [Problem] = []
                // Load each problem file
                for problemURL in problemFiles {
                    guard let data = try? Data(contentsOf: problemURL) else {
                        print("Failed to load problem file: \(problemURL.lastPathComponent)")
                        continue
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let problem = try decoder.decode(Problem.self, from: data)
                        problems.append(problem)
                    } catch {
                        print("Decoding error for problem \(problemURL.lastPathComponent)")
                    }
                }
                
                if problems.isEmpty { continue }
                
                // Create category with all its problems
                var category = Category(name: categoryName, problems: problems)
                
                // Load cached problems if any
                if let cachedProblems = loadProblems(for: categoryName) {
                    category.problems = cachedProblems
                }
                
                categories.append(category)
            }
            return categories
        } catch {
            print("Error reading categories directory")
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
