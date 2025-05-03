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
    @State private var offset: CGFloat = -300
    @State private var timer: Timer?
    
    private let visibleOffset: CGFloat = -250
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .font(.subheadline)
                        .padding(-3)
                }
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(isCorrect ? .green : .red)
                        
                        Text(isCorrect ? "Correct!" : "Wrong!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                    Text(feedbackMessage(when: isCorrect, for: message))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Text(isCorrect ? "Next problem" : "Error details")
                                .fontWeight(.semibold)
                                .padding()
                                .frame(height: 30)
                                .foregroundColor(.primary)
                                .cornerRadius(8)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            })
            .onAppear {
                withAnimation(.spring()) {
                    isVisible = true
                    offset = -250
                }
            }
            .edgesIgnoringSafeArea(.top)
            .frame(width: UIScreen.main.bounds.width - 100)
        }

    }
    
    private func dismiss() {
        onDismiss()
    }
    
    private func feedbackMessage(when isCorrect: Bool, for message: String) -> String {
    switch isCorrect {
    case true:
        return "Great job! Your solution is correct."
    case false:
        return "Oops! Check your solution again."
    }
    }
    
}

#Preview {
    VStack(spacing: 50) {
        // Correct Answer Modal
        AnswerFeedbackModal(
            isCorrect: true,
            message: "Great job! Your solution is correct.",
            onDismiss: { print("Dismissed correct modal") }
        )
        
        // Wrong Answer Modal
        AnswerFeedbackModal(
            isCorrect: false,
            message: "Oops! Check your errors and try again.",
            onDismiss: { print("Dismissed wrong modal") }
        )
    }
    .padding()
}

#Preview {
    VStack(spacing: 50) {
        // Correct Answer Modal
        AnswerFeedbackModal(
            isCorrect: true,
            message: "Great job! You selected the correct time and space complexity.",
            onDismiss: { print("Dismissed correct modal") }
        )
    }
}
