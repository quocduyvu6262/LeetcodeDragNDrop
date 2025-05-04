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
                SolutionView(problem: problem, nextStep: { currentStep = .description })
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            HStack {
                                Button("Back") {  currentStep = .description }
                            }
                        }
                        
                    }
            case .complexity:
                ComplexityView(problem: problem, nextStep: { currentStep = .description })
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Back") { currentStep = .solution }
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
        function: "def twoSum(array, target)",
        inputs: ["[2,7,11,15,19], 9"],
        outputs: ["[7, 2]"],
        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
        correctTimeComplexity: "O(n)",
        correctSpaceComplexity: "O(n)"
    )
    return NavigationStack {
        ProblemView(problem: sampleProblem)
    }
}
