//
//  DescriptionView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct DescriptionView: View {
    let problem: Problem
    let nextStep: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    Text(problem.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(problem.difficulty)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(difficultyColor.opacity(0.2))
                        )
                }
                .padding()
                .background(Color(.systemBackground))

                // Scrollable Middle Section
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(problem.description)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 0, maxHeight: .infinity)
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .padding(.horizontal)
                .frame(maxHeight: .infinity)

                NavigationLink(
                    destination:
                        SolutionView(problem: problem, nextStep: {})
                ) {
                    Text("Craft Your Solution")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(.blue.opacity(0.2))
                        .cornerRadius(12)
                }
                .padding(.top, 10)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color(.systemBackground))
        }
    }
    
    private var difficultyColor: Color {
        switch problem.difficulty.lowercased() {
        case "easy": return .green
        case "medium": return .orange
        case "hard": return .red
        default: return .gray
        }
    }
}

#Preview {
    @State var step: Int = 0

    let categories = DataManager.loadCategories()
    let twoPointerCategory = categories.first(where: { $0.name == "TwoPointers" })!
    let problem = twoPointerCategory.problems.first(where: { $0.name == "Three Sum" })!



    let sampleProblem = Problem(
        name: "Two Sum",
        difficulty: "Easy",
        description: "Given [2, 7, 11, 15] and target 9, find two numbers that add up.",
        snippets: [
            "hashmap = {}",
            "for num in array:",
            "if target - num in hashmap:",
            "return [num, hashmap[target - num]]",
            "hashmap[num] = num",
            "for i in array: for j in array:",
            "sort(array)"
          ],
        function: "def twoSum(array, target)",
        inputs: ["[2,7,11,15,19], 9"],
        outputs: ["[7, 2]"],
        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
        correctTimeComplexity: "O(n)",
        correctSpaceComplexity: "O(n)"
    )
    
    return NavigationStack {
        DescriptionView(problem: problem, nextStep: { })
    }
}
