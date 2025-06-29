//
//  CategoryCard.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/8/25.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    let problemCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("\(problemCount) problems")
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
                .stroke(Color.primary.opacity(1.0), lineWidth: 2)
        }

    }
}

//#Preview {
//    var step: Int = 0
//    let sampleProblem = Problem(
//        name: "Two Sum",
//        difficulty: "Easy",
//        description: "Given [2, 7, 11, 15] and target 9, find two numbers that add up.",
//        snippets: [
//            "hashmap = {}",
//            "for num in array:",
//            "if target - num in hashmap:",
//            "return [num, hashmap[target - num]]",
//            "hashmap[num] = num",
//            "for i in array: for j in array:",
//            "sort(array)"
//          ],
//        function: "def twoSum(array, target)",
//        inputs: ["[2,7,11,15,19], 9"],
//        outputs: ["[7, 2]"],
//        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
//        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
//        correctTimeComplexity: "O(n)",
//        correctSpaceComplexity: "O(n)"
//    )
//    
//    let sampleCategory = Category(name: "Two Pointer", problems: [sampleProblem])
//    
//    return NavigationStack {
//        CategoryCard(category: sampleCategory, problemCount: 0)
//    }
//}
