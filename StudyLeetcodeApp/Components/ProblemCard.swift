//
//  ProblemCard.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/9/25.
//

import SwiftUI

struct ProblemCard: View {
    let problem: Problem
    
    var body: some View {
        HStack {
            Text(problem.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(problem.difficulty)
                .font(.subheadline)
                .foregroundColor(difficultyColor(for: problem.difficulty))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(difficultyColor(for: problem.difficulty).opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(Color.black.opacity(1.0), lineWidth: 2)
        }
    }
    
    private func difficultyColor(for difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "easy":
            return .green
        case "medium":
            return .orange
        case "hard":
            return .red
        default:
            return .gray
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
        ProblemCard(problem: sampleProblem)
    }
}
