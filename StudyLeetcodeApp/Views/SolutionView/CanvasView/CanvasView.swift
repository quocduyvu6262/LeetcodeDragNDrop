//
//  CanvasView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/28/25.
//

import SwiftUI
import SwiftData

struct SnippetPositionPreferenceKey: PreferenceKey {
  static var defaultValue: [CodeSnippetType: CGRect] = [:]

  static func reduce(value: inout [CodeSnippetType: CGRect], nextValue: () -> [CodeSnippetType: CGRect]) {
    value.merge(nextValue()) { current, _ in current }
  }
}

struct CanvasView: View {
  // Parameters
  @Binding var droppedSnippets: [DroppedSnippet]
  @EnvironmentObject private var manager: StageManager<SnippetPreview.Model>
  
  // Variables
  let dotSpacing: CGFloat = Constants.dotSpacing
  let sizeFactor: CGFloat = 1.5
  @State private var snippetPositions: [CodeSnippetType: CGRect] = [:]
  @Query var savedSnippets: [DroppedSnippet]
  @Environment(\.modelContext) var modelContext

  
  // Closures
  let onDrop: (CodeSnippetType, CGPoint) -> Void
  
  var body: some View {
    GeometryReader { geometry in
      let frame = geometry.frame(in: .named("solutionView"))
      let canvasWidth = geometry.size.width * sizeFactor
      let canvasHeight = geometry.size.height * sizeFactor
      
      ScrollView([.vertical, .horizontal], showsIndicators: true) {
        ZStack(alignment: .topLeading) {
                    
          ForEach(1 ..< Int(canvasHeight / dotSpacing) + 1, id: \.self) { row in
            ForEach(1 ..< Int(canvasWidth / dotSpacing) + 1, id: \.self) { col in
              Circle()
                .frame(width: 3, height: 3)
                .opacity(0.3)
                .foregroundColor(.gray)
                .position(
                  x: CGFloat(col) * dotSpacing,
                  y: CGFloat(row) * dotSpacing
                )
            }
          }
          
          ForEach(droppedSnippets.indices, id: \.self) { index in
            let snippet = droppedSnippets[index].snippet
            let snippetPosition = droppedSnippets[index].position
            CodeSnippet(code: snippet.text)
              .background(
                GeometryReader { snippetGeometry in
                  Color.clear
                    .preference(key: SnippetPositionPreferenceKey.self, value: [
                      snippet: snippetGeometry
                        .frame(in: .named("solutionView")),
                    ])
                }
              )
              .position(snippetPosition)
          }
        }
        .frame(width: canvasWidth, height: canvasHeight)
        .onPreferenceChange(SnippetPositionPreferenceKey.self) { positions in
          snippetPositions = positions
        }
        .background(Color.clear.contentShape(Rectangle()))
        .dragAndDropRegion(
          id: RegionID("canvas"),
          dragHandler: makeCanvasDragHandler(),
          dropHandlers: [makeCanvasDropHandler()],
          fixedFrame: frame
        )
      }
      .disabled(!manager.currentItems.isEmpty)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .clipped()
    .overlay {
      RoundedRectangle(cornerRadius: 12.0)
        .stroke(Color.primary.opacity(1.0), lineWidth: 2)
    }
  }
}

extension CanvasView {

  private func makeCanvasDragHandler() -> DragHandler<SnippetPreview.Model> {
    DragHandler<SnippetPreview.Model>(
      updateKey: droppedSnippets, // re-evaluate when content moves
      dragInfoAtPoint: { pointInStage, _ in
        // hit a dropped snippet by comparing stage point to its stage-positioned frame
        if let (snippet, rect) = snippetPositions.first(where: { _, rect in
          rect.contains(pointInStage)
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
        if let idx = droppedSnippets.firstIndex(
          where: {$0.snippet == snippet
          }) {
          droppedSnippets.remove(at: idx)
        }
      },
      putBack: { (snippet: CodeSnippetType) in
        if let savedIndex = savedSnippets.firstIndex(where: { $0.snippet == snippet }) {
          droppedSnippets.append(savedSnippets[savedIndex])
        }
      }
    )
  }

  private func makeCanvasDropHandler() -> DropHandler<SnippetPreview.Model> {
    DropHandler(
      for: CodeSnippetType.self,
      updateKey: droppedSnippets,
      debug: "Canvas"
    ) { pointInStage, regionFrame, previewSize in
      return regionFrame
    } action: { (event, snippet: CodeSnippetType, pointInRegion) in
      switch event {
      case .dropStarted: break
      case .dropEnded:
        let snapped = snap(pointInRegion)
        onDrop(snippet, snapped)
      case .enter, .move, .exit: break
      }
    }
  }

  private func snap(_ p: CGPoint) -> CGPoint {
    let s = dotSpacing
    return CGPoint(x: round(p.x / s) * s, y: round(p.y / s) * s)
  }
}
