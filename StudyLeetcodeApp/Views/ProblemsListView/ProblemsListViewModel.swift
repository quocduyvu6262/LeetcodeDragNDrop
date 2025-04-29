//
//  ProblemsListViewModel.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/19/25.
//

import Foundation

class ProblemsListViewModel: ObservableObject {
    @Published var problems: [Problem] = []
    
    @Published var alertItem: AlertItem?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    
    private var category: Category
    
    init(category: Category) {
        self.category = category
        loadCachedProblems()
    }
    
    var filteredProblems: [Problem] {
        if searchText.isEmpty {
            return problems
        } else {
            return problems.filter { problem in
                problem.name.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))
            }
        }
    }
    
    private func loadCachedProblems() {
        self.problems = category.problems
        if let cachedProblems = DataManager.loadProblems(for: category.name) {
            self.problems = (self.problems + cachedProblems).uniqued()
        }
    }
    
    func loadMoreProblems(for category_name: String, onCompletion: @escaping (Int) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let newProblems = try await getProblems(for: category_name)
                await MainActor.run {
                    let allProblems = (self.problems + newProblems).uniqued()
                    
                    if allProblems.count == self.problems.count {
                        self.alertItem = AlertContext.enoughData
                    } else {
                        self.problems = allProblems
                        DataManager.saveProblems(self.problems, for: category.name)
                        self.category.problems = self.problems
                    }
                    self.isLoading = false
                    onCompletion(self.problems.count)
                }
            } catch LCError.invalidURL {
                await MainActor.run {
                    self.isLoading = false
                    self.alertItem = AlertContext.invalidURL
                }
            } catch LCError.invalidResponse {
                await MainActor.run {
                    self.isLoading = false
                    self.alertItem = AlertContext.invalidResponse
                }
            } catch LCError.invalidData {
                await MainActor.run {
                    self.isLoading = false
                    self.alertItem = AlertContext.invalidData
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertItem = AlertContext.unableToComplete
                }
            }
        }
    }
    
    func getProblems(for category_name: String) async throws -> [Problem] {
        let endpoint = "http://127.0.0.1:8000/api/v1/problems/\(category_name)"
        
        guard let url = URL(string: endpoint) else {
            throw LCError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw LCError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([Problem].self, from: data)
        } catch {
            throw LCError.invalidData
        }
    }
}

extension Array where Element == Problem {
    func uniqued() -> [Problem] {
        var seenNames = Set<String>()
        return filter { seenNames.insert($0.name).inserted }
    }
}
