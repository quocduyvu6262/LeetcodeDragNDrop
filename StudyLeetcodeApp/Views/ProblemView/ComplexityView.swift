//
//  ComplexityView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct ComplexityView: View {
    let problem: Problem
    let nextStep: () -> Void
    
    var body: some View {
        VStack {
          Text("What’s the time/space complexity?")
          ForEach(problem.complexityOptions, id: \.self) { option in
            Button(option) { /* Check logic later */ }
          }
          Button("Submit") { nextStep() } // Placeholder
        }
    }
}

#Preview {
    @State var step: Int = 0
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
        correctOrder: [0, 1, 2, 3, 4],
        correctIndentation: [0, 0, 4, 8, 4],
        complexityOptions: ["O(n²), O(1)", "O(n), O(n)", "O(n log n), O(1)", "O(1), O(n)"],
        correctComplexity: 1
    )
    return NavigationStack {
        ComplexityView(problem: sampleProblem, nextStep: { step = 2 })
    }
}
