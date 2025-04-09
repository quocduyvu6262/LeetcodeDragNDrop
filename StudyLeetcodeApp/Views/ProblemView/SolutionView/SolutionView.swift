//
//  SolutionView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI
import SwiftData

struct SolutionView: View {
    let problem: Problem
    let nextStep: () -> Void
    
    @Environment(\.modelContext) internal var modelContext
    @Query var savedSnippets: [DroppedSnippet]
    
    @State var droppedSnippets: [(snippet: String, position: CGPoint)] = []
    @State var availableSnippets: [String]
    
    @State private var currentSnippet: String = ""
    
    @State private var showModal: Bool = false
    @State private var isCorrect: Bool = false
    @State private var modalMessage: String = ""
    
    init(problem: Problem, nextStep: @escaping () -> Void) {
        self.problem = problem
        self.nextStep = nextStep
        _availableSnippets = State(initialValue: problem.snippets)
        let problemName = problem.name
        _savedSnippets = Query(filter: #Predicate<DroppedSnippet> { $0.problemName == problemName })
    }
    
    var body: some View {
        ZStack {
            VStack {
                // Top Half: Canvas
                CanvasView(
                    minCanvasHeight: UIScreen.main.bounds.height * 0.7,
                    droppedSnippets: droppedSnippets,
                    currentSnippet: $currentSnippet
                ) { snippet, position in
                    updateDroppedSnippets(snippet: snippet, position: position)
                }
                .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height * 0.50)
                
                // Bottom Half: Snippet List
                SnippetsListView(
                    availableSnippets: availableSnippets,
                    currentSnippet: $currentSnippet
                ) { snippet in
                    returnSnippetToAvailable(snippet: snippet)
                }
                .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.height * 0.30)
                Spacer()
                
                
                // Buttons
                
                HStack(spacing: 20) {
                    
                    LCButton(title: "Reset") {
                        for snippet in droppedSnippets {
                            returnSnippetToAvailable(snippet: snippet.snippet)
                        }
                    }
                    
                    LCButton(title: "Submit") {
                        let result = isSnippetsCorrect()
                        let isOrderCorrect = result.0
                        let isIndentCorrect = result.1
                        isCorrect = isOrderCorrect && isIndentCorrect
                        modalMessage = isCorrect ? "Great job! Your solution is correct." : "Oops! Check the order or indentation."
                        showModal = true
                    }
                }
            }
            
            if showModal {
                VStack {
                    AnswerFeedbackModal(
                        isCorrect: isCorrect, 
                        message: modalMessage
                    ) {
                        showModal = false
                        if isCorrect {
                            nextStep()
                        }
                    }
                }
            }
        }
        .onAppear {
            loadDroppedSnippets()
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
        SolutionView(problem: sampleProblem, nextStep: { step = 2 })
    }
}
