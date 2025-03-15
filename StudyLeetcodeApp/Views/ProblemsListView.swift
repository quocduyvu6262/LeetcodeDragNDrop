//
//  CategoryView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct ProblemsListView: View {
    let category: Category
    
    @State private var searchText: String = ""
    
    private var filteredProblems: [Problem] {
        if searchText.isEmpty {
            return category.problems
        } else {
            return category.problems.filter { problem in
                problem.name.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search problem name...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(filteredProblems) { problem in
                        NavigationLink(destination: ProblemView(problem: problem)) {
                            ProblemCard(problem: problem)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(category.name)
        }
    }
}

#Preview {
    @State var step: Int = 0
    let sampleProblem = Problem(
        name: "Two Sum",
        difficulty: "Easy",
        description: """
                    Given an array of integers nums and an integer target, find two numbers that add up to the target and return their indices. Each input has exactly one solution, and you cannot use the same element twice. Order of indices doesn’t matter.
                    
                    Example
                    nums = [2, 7, 11, 15], target = 9
                    2 + 7 = 9, so return [0, 1]
                    """,
        snippets: [
            "hashmap = {}",
            "for num in array:",
            "if target - num in hashmap:",
            "return [num, hashmap[target - num]]",
            "hashmap[num] = num",
            "for i in array: for j in array:",
            "sort(array)"
          ],
        correctOrder: [0, 1, 2, 3, 4],
        correctIndentation: [0, 0, 4, 8, 4],
        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
        correctTimeComplexity: "O(n)",
        correctSpaceComplexity: "O(n)"
    )
    
    let sampleCategory = Category(name: "Two Pointer", problems: [sampleProblem])
    
    return NavigationStack {
        ProblemsListView(category: sampleCategory)
    }
}

