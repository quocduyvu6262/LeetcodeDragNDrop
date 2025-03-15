//
//  CategoryCard.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/8/25.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("100 problems")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .overlay {
            RoundedRectangle(cornerRadius: 12.0)
                .stroke(Color.black.opacity(1.0), lineWidth: 2)
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
        CategoryCard(category: sampleCategory)
    }
}
