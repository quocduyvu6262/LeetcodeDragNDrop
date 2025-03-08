//
//  AnswerFeedbackModal.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/5/25.
//

import SwiftUI

struct AnswerFeedbackModal: View {
    let isCorrect: Bool
    let message: String
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(isCorrect ? .green : .red)
            
            Text(isCorrect ? "Correct!" : "Wrong!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            LCButton(
                title: isCorrect ? "Next" : "Try Again",
                action: {
                    withAnimation(.spring()) {
                        isVisible = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                },
                backgroundColor: isCorrect ? .green.opacity(0.2) : .red.opacity(0.2),
                foregroundColor: isCorrect ? .green : .red
            )
            .frame(maxWidth: 200)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .frame(maxWidth: 300)
        .offset(y: isVisible ? 0 : -300) // Slide from top
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        // Correct Answer Modal
        AnswerFeedbackModal(
            isCorrect: true,
            message: "Great job! You selected the correct time and space complexity.",
            onDismiss: { print("Dismissed correct modal") }
        )
        
        // Wrong Answer Modal
        AnswerFeedbackModal(
            isCorrect: false,
            message: "Oops! Check your selections and try again.",
            onDismiss: { print("Dismissed wrong modal") }
        )
    }
    .padding()
    .background(Color(.systemGray6)) // Light background for contrast
}
