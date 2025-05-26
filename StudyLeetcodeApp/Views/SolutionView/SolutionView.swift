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
    
    @EnvironmentObject var snippetHistoryManger: SnippetHistoryManager
    var snippetHistory: SnippetHistory {snippetHistoryManger.history(for: problem)}
    @Environment(\.modelContext) internal var modelContext
    @Query var savedSnippets: [DroppedSnippet]
    @State private var webView: WKWebView? = nil
    @State private var showModal: Bool = false
    @State private var isCorrect: Bool = false
    @State private var modalMessage: String = ""
    @State var pythonExecutorCode: String = ""
    @State var runPython: Bool = false
    
    // Canvas Variables
    @State var droppedSnippets: [(snippet: String, position: CGPoint)] = []
    
    // SnippetList Variables
    @State var availableSnippets: [String]
    
    // Shared Canvas and SnippetList Variables
    @StateObject var dragCoordinator: DragDropCoordinator = DragDropCoordinator()
    @State var highlightedDot: CGPoint? = nil
    
    init(problem: Problem, nextStep: @escaping () -> Void) {
        self.problem = problem
        self.nextStep = nextStep
        _availableSnippets = State(initialValue: problem.snippets)
        let problemName = problem.name
        _savedSnippets = Query(filter: #Predicate<DroppedSnippet> { $0.problemName == problemName })
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                VStack(spacing: 10) {
                    // 60% CanvasView
                    CanvasView(
                        minCanvasHeight: calculatedCanvasHeight(for: geometry),
                        canvasFrameHeight: geometry.size.height * Constants.canvasHeightFactor,
                        droppedSnippets: droppedSnippets,
                        coordinator: dragCoordinator,
                        highlightedDot: $highlightedDot,
                        onDrop: { snippet, position in
                            dropOnCanvas(snippet: snippet, position: position)
                        },
                        onDragToList: { snippet in
                            dropOnList(snippet: snippet)
                        }
                    )
                    .frame(height: geometry.size.height * Constants.canvasHeightFactor)
                    .padding(.horizontal, 10)
                    
                    // 25% Snippet List
                    SnippetsListView(
                        availableSnippets: availableSnippets,
                        coordinator: dragCoordinator,
                        highlightedDot: $highlightedDot,
                        onDrop: { snippet in
                            dropOnList(snippet: snippet)
                        },
                        onDragToCanvas: { snippet, position in
                            dropOnCanvas(snippet: snippet, position: position)
                        }
                    )
                    .frame(height: geometry.size.height * 0.25)
                    .padding(.horizontal, 10)

                    // 15% Buttons
                    HStack {
                        LCButton(title: "Submit") {
                            submit()
                        }
                    }
                    .frame(height: geometry.size.height * 0.065)
                    .padding(.horizontal, 10)
                }
                
                if dragCoordinator.isDragging {
                   DraggedSnippetOverlay(
                       snippet: dragCoordinator.currentSnippet,
                       position: CGPoint(
                        x: dragCoordinator.dragPosition?.x ?? 0,
                        y: (dragCoordinator.dragPosition?.y ?? 0) + geometry.safeAreaInsets.top
                    )
                   )
                   .ignoresSafeArea()
                   .padding(.horizontal, 10)
               }
            }
            .coordinateSpace(name: "solutionView")
            
            if showModal {
                VStack {
                    AnswerFeedbackModal(
                        isCorrect: isCorrect, 
                        message: modalMessage,
                        showModal: $showModal
                    ) {
                        nextStep()
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
                    
                    LoadingModal()
                }
            }
        }
        .onAppear {
            loadDroppedSnippets()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    HStack(spacing: 5) {
                        Button {
                            undo()
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                        }

                        Button {
                            redo()
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                        }
                    }
                    Menu {
                        Button("Show Hint") {
                        }
                        Button("Show Solution") {
                            
                        }
                        Divider()
                        Button("Reset All", role: .destructive, action: resetAll)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }
            }
        }
    }
    
    private func dropOnCanvas(snippet: String, position: CGPoint) {
        if !isSnippetInBounds(for: snippet, at: position) {
            return
        }
        
        // Update SwiftData
        updateDroppedSnippets(snippet: snippet, position: position)
        
        // Update dropped snippets with reflowing
        let reflowedSnippets = reflowSnippets(droppedSnippets)
        droppedSnippets = reflowedSnippets
        
        // Snippet on SnippetHistory
        let snapshot = SnippetSnapshot(dropped: droppedSnippets)
        snippetHistory.push(snapshot)
    }
    
    private func dropOnList(snippet: String) {
        // Snippet on SwiftData
        returnSnippetToAvailable(snippet: snippet)
        
        // Snippet on SnippetHistory
        let snapshot = SnippetSnapshot(dropped: droppedSnippets)
        snippetHistory.push(snapshot)
    }
    
    private func calculatedCanvasHeight(for geometry: GeometryProxy) -> CGFloat {
        let maxY = droppedSnippets.map { $0.position.y }.max() ?? 0
        return max(geometry.size.height * Constants.minCanvasHeightFactor, maxY + Constants.snippetHeight)
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
        spaceComplexityOptions: ["O(1)", "O(n)", "O(2ⁿ)", "O(n!)"],
        correctTimeComplexity: "O(n)",
        correctSpaceComplexity: "O(n)"
    )

    return NavigationStack {
        SolutionView(problem: sampleProblem, nextStep: {})
            .environmentObject(SnippetHistoryManager()) // provide required environment objects
    }
}

