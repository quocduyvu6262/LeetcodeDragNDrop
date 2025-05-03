//
//  LoadingModal.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/2/25.
//

import SwiftUI

struct LoadingModal: View {
    var title: String?
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                ProgressView(title ?? "Running your Python code...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                    .padding()
                    .background(Color(uiColor: .systemBackground))
                    .cornerRadius(12)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
            }
        }
    }
}

#Preview {
    LoadingModal()
}
