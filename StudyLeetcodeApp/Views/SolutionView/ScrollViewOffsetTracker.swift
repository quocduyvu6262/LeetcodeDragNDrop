//
//  ScrollViewOffsetTracker.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/19/25.
//
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}

struct ScrollViewOffsetTracker: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetPreferenceKey.self,
                    value: geo.frame(in: .named("scrollView")).origin
                )
        }
        .frame(height: 0)
    }
}

