//
//  ProblemView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

enum ProblemStep {
    case description
    case solution
    case complexity
}

struct ProblemView: View {
    let problem: Problem
    @State private var currentStep: ProblemStep = .description
    
    var body: some View {
        VStack {
            switch(currentStep) {
            case .description:
                DescriptionView(problem: problem, nextStep: { currentStep = .solution })
            case .solution:
                SolutionView(problem: problem, nextStep: { currentStep = .complexity })
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Back") {  currentStep = .description }
                        }
                    }
            case .complexity:
                ComplexityView(problem: problem, nextStep: { })
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Back") {  currentStep = .solution }
                        }
                    }
            }
        }
    }
}

#Preview {
    
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
        ProblemView(problem: sampleProblem)
    }
}
