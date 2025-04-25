//
//  SolutionView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI
import SwiftData
import WebKit

struct SolutionView: View {
    let problem: Problem
    let nextStep: () -> Void
    
    @Environment(\.modelContext) internal var modelContext
    @Query var savedSnippets: [DroppedSnippet]
    
    @State private var webView: WKWebView? = nil
    
    @State var droppedSnippets: [(snippet: String, position: CGPoint)] = []
    @State var availableSnippets: [String]
    
    @State private var currentSnippet: String = ""
    
    @State private var showModal: Bool = false
    @State private var isCorrect: Bool = false
    @State private var modalMessage: String = ""
    
    @State private var pythonExecutorCode: String = ""
    @State private var runPython: Bool = false
    
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
                        submit()
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
            
            if runPython {
                ZStack {
                    PythonExecutorView(codeToRun: pythonExecutorCode, webViewRef: $webView) { success, output in
                        isCorrect = success
                        modalMessage = success ? "Success: \(output)" : "Logic error: \(output)"
                        showModal = true
                        runPython = false
                    }
                    .frame(width: 0, height: 0)
                }
            }
        }
        .onAppear {
            loadDroppedSnippets()
        }
    }
    
    func submit() {
        let userCode = buildCodeFromDroppedSnippets(droppedSnippets)
        let wrappedCode = 
"""
def user_function(array, target):
\(userCode)

array = [2, 7, 11, 15]
target = 9

result = user_function(array, target)

assert result == [0, 1]

import json
print(json.dumps({"success": True, "output": result}))
"""
        
        DispatchQueue.main.async {
            pythonExecutorCode = wrappedCode
            runPython = true
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
