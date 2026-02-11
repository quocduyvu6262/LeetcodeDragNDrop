//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetsListView: View {
  // Parameters
  @Binding var availableSnippets: [CodeSnippetType]
  @EnvironmentObject private var manager: StageManager<SnippetPreview.Model>

  // Variables
  private let dotSpacing: CGFloat = Constants.dotSpacing
  @State private var snippetPositions: [CodeSnippetType: CGRect] = [:]
  @State private var frameInStage: CGRect = .zero
  
  // Closures
  let onDrop: (CodeSnippetType) -> Void

  var body: some View {
    ScrollView([.vertical], showsIndicators: true) {
      VStack {
        ForEach(availableSnippets.indices, id: \.self) { index in
          let snippet = availableSnippets[index]
          CodeSnippet(code: snippet.text)
            .background(
              GeometryReader { snippetGeometry in
                Color.clear
                  .preference(key: SnippetPositionPreferenceKey.self, value: [
                    snippet: snippetGeometry.frame(in: .named("solutionView")),
                  ])
              }
            )
        }
      }
      .frame(width: frameInStage.width)
      .frame(minHeight: frameInStage.height)
      .onPreferenceChange(SnippetPositionPreferenceKey.self) { positions in
        snippetPositions = positions
      }
      .background(Color.clear.contentShape(Rectangle()))
      .dragAndDropRegion(
        id: RegionID("snippetList"),
        dragHandler: makeListDragHandler(),
        dropHandlers: [makeListDropHandler()],
        fixedFrame: frameInStage
      )
    }
    .disabled(!manager.currentItems.isEmpty)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .clipped()
    .background {
      GeometryReader { proxy in
        Color.clear
          .onChange(
            of: proxy.frame(in: .named("solutionView")),
            initial: true
          ) { _, newValue in
            frameInStage = newValue
          }
      }
    }
    .overlay {
      RoundedRectangle(cornerRadius: 12.0)
        .stroke(Color.primary.opacity(1.0), lineWidth: 2)
    }
  }

  private func makeListDragHandler() -> DragHandler<SnippetPreview.Model> {
    DragHandler<SnippetPreview.Model>(
      updateKey: snippetPositions,
      dragInfoAtPoint: {
        pointInStage,
        _ in
        if let (snippet, rect) = snippetPositions.first(
          where: { _, rect in rect.contains(pointInStage)
          }) {
          return DragModel(
            draggedItem: snippet,
            initialFrame: rect,
            previewModel: .init(text: snippet.text)
          )
        }
        return nil
      },
      pickedUp: { (snippet: CodeSnippetType) in
        if let idx = availableSnippets.firstIndex(where: {$0 == snippet}) {
          availableSnippets.remove(at: idx)
        }
      },
      putBack: { (snippet: CodeSnippetType) in
        availableSnippets.append(snippet)
      }
    )
  }

  private func makeListDropHandler() -> DropHandler<SnippetPreview.Model> {
    DropHandler(
      for: CodeSnippetType.self,
      updateKey: snippetPositions,
      debug: "List"
    ) { pointInStage, regionFrame, previewSize in
      return regionFrame // leave it like this d
    } action: { event, snippet, _ in
      onDrop(snippet)
    }
  }
}
