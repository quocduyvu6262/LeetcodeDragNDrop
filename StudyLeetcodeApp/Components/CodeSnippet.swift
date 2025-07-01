//
//  CodeSnippet.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct LineRectsPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue()) { (current, new) in new } // Merge dictionaries
    }
}

struct CodeSnippet: View {
    let code: String
    let width: CGFloat
    let lines: [String]
    private static let coordinateSpaceName = "codeSnippetContent"

    @State private var lineRects: [Int: CGRect] = [:]
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
        if lines.count == 1 {
            singleLineView(lines[0])
        } else {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: Constants.snippetSpacing) {
                    ForEach(lines.indices, id: \.self) { index in
                        let line = lines[index]
                        let (indentationWidth, contentWidth) = calculateLineDimensions(line)
                        
                        HStack(spacing: 0) {
                            // Indentation space
                            if indentationWidth > 0 {
                                Spacer()
                                    .frame(width: indentationWidth)
                            }
                            // Actual content with background
                            Text(line.trimmingCharacters(in: .whitespaces))
                                .font(Font(Constants.snippetFont))
                                .lineLimit(1)
                                .frame(width: contentWidth, height: Constants.snippetHeight, alignment: .leading)
                                .padding(.leading, 5)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(colorScheme == .dark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color.white)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.primary.opacity(0.45), lineWidth: 0.8)
                                }
                                .background(GeometryReader { geo in
                                    Color.clear.preference(key: LineRectsPreferenceKey.self, value: [index: geo.frame(in: .named(Self.coordinateSpaceName))])
                                })
                        }
                    }
                }
            }
            .padding(.vertical, 8)
            .frame(width: self.width, height: calculateTotalHeight(), alignment: .leading)
            .coordinateSpace(name: Self.coordinateSpaceName) // Define the named coordinate space here
                    // Listen for preference key changes here
            .onPreferenceChange(LineRectsPreferenceKey.self) { preferences in
                lineRects = preferences
                // You can print the positions here to verify
            }
        }
    }
}

extension CodeSnippet {
    private func singleLineView(_ line: String) -> some View {
        Text(line)
            .font(Font(Constants.snippetFont))
            .lineLimit(1)
            .padding(.leading, 5)
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

extension CodeSnippet {
    private func calculateTotalHeight() -> CGFloat {
        // Base height for single line
        let baseHeight = Constants.snippetHeight

        // If only one line, return base height
        guard lines.count > 1 else { return baseHeight }

        let totalSnippetHeight = baseHeight * CGFloat(lines.count)
        let totalSnippetHeightWithSpacing = totalSnippetHeight + Constants.snippetSpacing * CGFloat(lines.count - 1)

        return totalSnippetHeightWithSpacing
    }

    private func calculateLineDimensions(_ line: String) -> (indentation: CGFloat, content: CGFloat) {
        let indentation = line.prefix(while: { $0 == "\u{00A0}" })
        let content = line.dropFirst(indentation.count)

        // Use a fixed width for each space character
        let spaceWidth: CGFloat = 12 // Adjust this value to match your font
        let indentationWidth = CGFloat(indentation.count) * spaceWidth
        let contentWidth = calculateSnippetWidth(text: String(content))

        return (indentationWidth, contentWidth)
    }
}


#Preview {
    CodeSnippet(code: "if current_sum == 0:\n    result.append([nums[i], nums[left], nums[right]])\n    while left < right and nums[left] == nums[left+1]:\n        left += 1\n    while left < right and nums[right] == nums[right-1]:\n        right -= 1\n    left += 1\n    right -= 1")
}
