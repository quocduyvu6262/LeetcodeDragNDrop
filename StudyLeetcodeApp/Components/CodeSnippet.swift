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
    let lines: [String]
    @Environment(\.colorScheme) var colorScheme
    
    init(code: String) {
        self.code = code
        self.lines = code.components(separatedBy: .newlines).map { line in
           // Preserve indentation by replacing spaces with non-breaking spaces
           let indentation = line.prefix(while: { $0 == " " })
           let codeContent = line.dropFirst(indentation.count)
           return String(repeating: "\u{00A0}", count: indentation.count) + codeContent
       }
       // Calculate width based on the longest line
       self.width = lines.map { calculateSnippetWidth(text: $0) }.max() ?? calculateSnippetWidth(text: code)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.snippetSpacing) {
            ForEach(lines.indices, id: \.self) { index in
                Text(lines[index])
                    .font(Font(Constants.snippetFont))
                    .frame(height:Constants.snippetHeight)
            }
        }
        .padding(.leading, 5)
        .frame(width: self.width, height: calculateTotalHeight(), alignment: .leading)
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.white)
//        )
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.primary.opacity(0.45), lineWidth: 0.8)
        }
    }

    private func calculateTotalHeight() -> CGFloat {
        // Base height for single line
        let baseHeight = Constants.snippetHeight

        // If only one line, return base height
        guard lines.count > 1 else { return baseHeight }

        let totalSnippetHeight = baseHeight * CGFloat(lines.count)
        let totalSnippetHeightWithSpacing = totalSnippetHeight + Constants.snippetSpacing * CGFloat(lines.count - 1)

        return totalSnippetHeightWithSpacing
    }
}

#Preview {
    CodeSnippet(code: "if current_sum == 0:\n    result.append([nums[i], nums[left], nums[right]])\n    while left < right and nums[left] == nums[left+1]:\n        left += 1\n    while left < right and nums[right] == nums[right-1]:\n        right -= 1\n    left += 1\n    right -= 1")
}
