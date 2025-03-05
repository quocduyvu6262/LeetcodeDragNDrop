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
    
    @State var selectedTimeComplexity: String?
    @State var selectedSpaceComplexity: String?
    
    var body: some View {
        VStack(spacing: 30) {
            // Time Complexity Section
            VStack(spacing: 15) {
                Text("What’s the Time Complexity?")
                    .font(.headline)
                
                ForEach(problem.timeComplexityOptions, id: \.self) { option in
                    Button(action: {
                        selectedTimeComplexity = option
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedTimeComplexity == option ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            
            // Space Complexity Section
            VStack(spacing: 15) {
                Text("What’s the Space Complexity?")
                    .font(.headline)
                
                ForEach(problem.spaceComplexityOptions, id: \.self) { option in
                    Button(action: {
                        selectedSpaceComplexity = option
                    }) {
                        Text(option)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedSpaceComplexity == option ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 12)
            
            // Submit Button
            LCButton(title: "Submit") {
                if isCorrectComplexity() {
                    nextStep()
                }
            }
            .disabled(selectedTimeComplexity == nil || selectedSpaceComplexity == nil)
            .padding()
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
        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
        correctTimeComplexity: "O(n)",
        correctSpaceComplexity: "O(n)"
    )
    return NavigationStack {
        ComplexityView(problem: sampleProblem, nextStep: { step = 2 })
    }
}
