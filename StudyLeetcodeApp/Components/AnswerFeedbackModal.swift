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
    @Binding var showModal: Bool
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    @State private var offset: CGFloat = -300
    @State private var timer: Timer?
    @State private var showErrorDetails = false
    
    private let visibleOffset: CGFloat = -250
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .topTrailing) {
                Button(action: {
                    showModal = false
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
                        if isCorrect {
                            Button(action: {
                                onDismiss()
                            }) {
                                Text("Next problem")
                                    .fontWeight(.semibold)
                                    .padding(.top, 8)
                                    .frame(height: 30)
                                    .foregroundColor(.primary)
                            }
                        } else {
                            Button(action: {
                                withAnimation {
                                    showErrorDetails.toggle()
                                }
                            }) {
                                VStack {
                                    Text(showErrorDetails ? "Collapse details" : "Error details")
                                        .fontWeight(.semibold)
                                        .padding(.top, 8)
                                        .frame(height: 30)
                                        .foregroundColor(.primary)
                                    if showErrorDetails {
                                        ScrollView {
                                            Text(message)
                                                .font(.system(.body, design: .monospaced))
                                                .foregroundColor(.red)
                                                .padding(8)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color(.systemGray6))
                                                .cornerRadius(8)
                                        }
                                        .frame(maxHeight: 100)
                                        .transition(.opacity.combined(with: .move(edge: .top)))
                                    }
                                }
                            }
                        }
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
    @State var showModal = true

    VStack(spacing: 50) {
        // Correct Answer Modal
        AnswerFeedbackModal(
            isCorrect: true,
            message: "Great job! Your solution is correct.",
            showModal: $showModal,
            onDismiss: { print("Dismissed correct modal") }
        )
        
        // Wrong Answer Modal
        AnswerFeedbackModal(
            isCorrect: false,
            message: "Oops! Check your errors and try again.",
            showModal: $showModal,
            onDismiss: { print("Dismissed wrong modal") }
        )
    }
    .padding()
}

#Preview {
    @State var showModal = true
    VStack(spacing: 50) {
        // Correct Answer Modal
        AnswerFeedbackModal(
            isCorrect: true,
            message: "Great job! You selected the correct time and space complexity.",
            showModal: $showModal,
            onDismiss: { print("Dismissed correct modal") }
        )
    }
}
