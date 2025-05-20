//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetsListView: View {
    let availableSnippets: [String]
    @Binding var currentSnippet: String

    let onDrop: (String) -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                FlowLayout {
                    ForEach(availableSnippets, id: \.self) { snippet in
                        CodeSnippet(code: snippet)
                            .offset(currentSnippet == snippet ? dragOffset : .zero)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        currentSnippet = snippet
                                        dragOffset = value.translation
                                    }
                                    .onEnded { _ in
                                        dragOffset = .zero
                                    }
                            )
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 20)
                .padding(10.0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(true ? Color.blue : Color.primary.opacity(1.0), lineWidth: 2)
            }
        }
    }
}
