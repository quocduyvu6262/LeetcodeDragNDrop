//
//  SolutionView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftData
import SwiftUI
import WebKit

struct SolutionView: View {
  // Parameters
  let problem: Problem
  let nextStep: () -> Void

  // Variables
  var snippetHistory: SnippetHistory { snippetHistoryManger.history(for: problem) }
  @Query var savedSnippets: [DroppedSnippet]
  @EnvironmentObject var snippetHistoryManger: SnippetHistoryManager
  @Environment(\.modelContext) var modelContext
  @State private var webView: WKWebView?
  @State private var showModal: Bool = false
  @State private var isCorrect: Bool = false
  @State private var modalMessage: String = ""
  @State var pythonExecutorCode: String = ""
  @State var runPython: Bool = false

  // CanvasView Variables
  @State var droppedSnippets: [DroppedSnippet] = []

  // SnippetListView Variables
  @State var availableSnippets: [CodeSnippetType]

  init(problem: Problem, nextStep: @escaping () -> Void) {
    self.problem = problem
    self.nextStep = nextStep
    _availableSnippets = State(initialValue: problem.snippets)
    let problemName = problem.name
    _savedSnippets = Query(filter: #Predicate<DroppedSnippet> { $0.snippet.problemName == problemName })
  }

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        VStack(spacing: 10) {
          // 68% CanvasView
          CanvasView(
            droppedSnippets: $droppedSnippets,
            onDrop: { snippet, position in
              dropOnCanvas(snippet: snippet, position: position)
            },
          )
          .frame(height: geometry.size.height * Constants.canvasHeightFactor)

          // 25% Snippet List
          SnippetsListView(
            availableSnippets: $availableSnippets,
            onDrop: { snippet in
              dropOnList(snippet: snippet)
            }
          )
          .frame(height: geometry.size.height * 0.25)

          // 15% Buttons
          HStack {
            LCButton(title: "Submit") {
              submit()
            }
          }
        }
      }
      .coordinateSpace(name: "solutionView")
      .enableNiceDragAndDrop(SnippetPreview.self)
      .padding(.horizontal, 10)

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
              // TODO:
            }
            Button("Show Solution") {
              // TODO:
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
}
