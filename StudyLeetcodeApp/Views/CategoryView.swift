//
//  CategoryView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct CategoryView: View {
    let category: Category
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ForEach(category.problems) { problem in
                    NavigationLink(destination: ProblemView(problem: problem)) {
                        HStack {
                            Text("\(problem.name) - \(problem.difficulty)")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                    }
                    Divider()
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle(category.name)
    }
}
//
//#Preview {
//    let sampleCategory = Category(
//        name: "Two Pointer",
//        problems: [
//            Problem(
//                name: "Two Sum",
//                difficulty: "Easy",
//                description: "Given [2, 7, 11, 15] and target 9, find two numbers that add up.",
//                snippets: ["hashmap = {}", "for num in array:", "if target - num in hashmap:", "return [num, hashmap[target - num]]", "hashmap[num] = num"],
//                correctOrder: [0, 1, 2, 3, 4],
//                correctIndentation: [0, 0, 4, 8, 4],
//                complexityOptions: ["O(n²), O(1)", "O(n), O(n)", "O(n log n), O(1)", "O(1), O(n)"],
//                correctComplexity: 1
//            ),
//            Problem(
//                name: "Container With Most Water",
//                difficulty: "Medium",
//                description: "Given heights array, find max area...",
//                snippets: ["left = 0", "right = array.count - 1", "while left < right:", "area = min(array[left], array[right])", "left += 1"],
//                correctOrder: [0, 1, 2, 3, 4],
//                correctIndentation: [0, 0, 0, 4, 4],
//                complexityOptions: ["O(n²), O(1)", "O(n), O(1)", "O(n log n), O(1)", "O(1), O(n)"],
//                correctComplexity: 1
//            )
//        ]
//    )
//    
//    return NavigationStack {
//        CategoryView(category: sampleCategory)
//    }
//}
