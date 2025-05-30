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
        
        guard let categoriesURL = Bundle.main.url(forResource: "ProblemCategories", withExtension: nil) else {
            print("Failed to find ProblemCategories directory")
            return []
        }
        
        var categories: [Category] = []
        
        do {
            // Get all category directories
//            let categoryDirectories = try fileManager.contentsOfDirectory(at: categoriesURL, includingPropertiesForKeys: nil)
//            
//            for categoryURL in categoryDirectories {
//                // Skip if not a directory
//                guard categoryURL.hasDirectoryPath else { continue }
//                
//                // Get category name from directory name
//                let categoryName = categoryURL.lastPathComponent
//                
//                // Try to load problems.json from this category
//                let problemsURL = categoryURL.appendingPathComponent("problems.json")
//                guard let data = try? Data(contentsOf: problemsURL) else {
//                    print("Failed to load problems.json for category: \(categoryName)")
//                    continue
//                }
//                
//                do {
//                    let decoder = JSONDecoder()
//                    let problems = try decoder.decode([Problem].self, from: data)
//                    
//                    // Create category with standardized name
//                    var category = Category(name: categoryName, problems: problems)
//                    categories.append(category)
//                    
//                    // Load cached problems if any
//                    if let cachedProblems = loadProblems(for: categoryName) {
//                        category.problems = cachedProblems
//                    }
//                } catch {
//                    print("Decoding error for category \(categoryName): \(error)")
//                }
//            }
//            
            return categories
        } catch {
            print("Error reading categories directory: \(error)")
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
