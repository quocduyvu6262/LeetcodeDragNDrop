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
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        .frame(maxWidth: 300)
        .offset(y: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = visibleOffset + value.translation.height
                }
                .onEnded { value in
                    if value.translation.height < -50 {
                        dismiss()
                    } else {
                        withAnimation(.spring()) {
                            offset = visibleOffset
                        }
                    }
                }
        )
        .onAppear {
            withAnimation(.spring()) {
                isVisible = true
                offset = -250
            }
            startAutoDismissTimer()
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private func startAutoDismissTimer(seconds: TimeInterval = 3.0) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { _ in
            dismiss()
        }
    }
    
    private func dismiss() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8, blendDuration: 0)) {
            isVisible = false
            offset = visibleOffset * 3
        }
        timer?.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            onDismiss()
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
