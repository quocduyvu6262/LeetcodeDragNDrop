//
//  CodeSnippet.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI
 
struct CodeSnippet: View {
    let code: String
    let width: CGFloat
    
    init(code: String) {
        self.code = code
        self.width = calculateSnippetWidth(text: code)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(code)
                .font(Font(Constants.snippetFont))
                .padding(.leading, 5.0)
            Spacer()
        }
        .frame(width: self.width, height: Constants.snippetHeight)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        }

    }
}

#Preview {
    CodeSnippet(code: "if (problem.name) == \"Two Sum\"")
}
