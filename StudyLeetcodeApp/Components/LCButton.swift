//
//  LCButton.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/5/25.
//

import SwiftUI

struct LCButton: View {
    let title: String
    let action: () -> Void
    let backgroundColor: Color
    let foregroundColor: Color
    let cornerRadius: CGFloat
    let font: Font
    
    init(
        title: String,
        action: @escaping () -> Void,
        backgroundColor: Color = .gray.opacity(0.1),
        foregroundColor: Color = .primary,
        cornerRadius: CGFloat = 8,
        font: Font = .headline
    ) {
        self.title = title
        self.action = action
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.cornerRadius = cornerRadius
        self.font = font
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(font)
                .foregroundColor(foregroundColor)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // Default style
        LCButton(title: "Default Button") {
            print("Default button tapped")
        }
        
        // Custom style
        LCButton(
            title: "Custom Button",
            action: { print("Custom button tapped") },
            backgroundColor: .green,
            foregroundColor: .black,
            cornerRadius: 12,
            font: .body
        )
        
        // Minimal style
        LCButton(
            title: "Minimal",
            action: { print("Minimal tapped") }
        )
    }
    .padding()
}
