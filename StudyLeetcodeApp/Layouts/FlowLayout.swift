//
//  FlowLayout.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI


struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize,
                      subviews: Subviews,
                      cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes,
                      spacing: spacing,
                      containerWidth: containerWidth).size
    }
    
    func placeSubviews(in bounds: CGRect,
                       proposal: ProposedViewSize,
                       subviews: Subviews,
                       cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets =
            layout(sizes: sizes,
                   spacing: spacing,
                   containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: .init(x: offset.x + bounds.minX,
                                    y: offset.y + bounds.minY),
                                    proposal: .unspecified)
        }
    }
    
    func layout(sizes: [CGSize],
                 spacing: CGFloat = 8,
                 containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
        var result: [CGPoint] = []
        var currentPosition: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var maxX: CGFloat = 0
        for size in sizes {
            if currentPosition.x + size.width > containerWidth {
                 currentPosition.x = 0
                 currentPosition.y += lineHeight + spacing
                 lineHeight = 0
             }
             result.append(currentPosition)
             currentPosition.x += size.width
             maxX = max(maxX, currentPosition.x)
             currentPosition.x += spacing
             lineHeight = max(lineHeight, size.height)
         }
         return (result, .init(width: maxX, height: currentPosition.y + lineHeight))
     }
}

#Preview {
    let items = [
        "hashmap = {}",
        "for num in array:",
        "if target - num in hashmap:",
        "return [num, hashmap[target - num]]",
        "hashmap[num] = num",
        "for i in array: for j in array:",
        "sort(array)",
        "return [num, hashmap[target - num]]",
        "hashmap[num] = num",
        "for i in array: for j in array:",
        "sort(array)",
        
    ]
    
    return FlowLayout {
        ForEach(items, id: \.self) { item in
            CodeSnippet(code: item)
                .padding(3.0)
        }
    }
    .overlay {
        RoundedRectangle(cornerRadius: 12.0)
            .stroke(Color.black.opacity(1.0), lineWidth: 2)
    }
}
