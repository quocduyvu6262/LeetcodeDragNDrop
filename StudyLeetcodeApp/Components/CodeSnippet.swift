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
    @Environment(\.colorScheme) var colorScheme
    
    init(code: String) {
        self.code = code
        self.width = calculateSnippetWidth(text: code)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(code)
                .font(Font(Constants.snippetFont))
                .padding(.leading, 5.0)
        }
        .frame(width: self.width, height: Constants.snippetHeight, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.white)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.45), lineWidth: 0.8)
        }
    }
}

#Preview {
    CodeSnippet(code: "if (problem.name) == \"Two Sum\"")
}
