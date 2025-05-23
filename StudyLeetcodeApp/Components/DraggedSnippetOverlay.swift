//
//  DraggedSnippetOverlay.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/19/25.
//

import SwiftUI

struct DraggedSnippetOverlay: View {
    let snippet: String
    let position: CGPoint
    
    var body: some View {
        CodeSnippet(code: snippet)
            .position(position)
    }
}
