//
//  ScrollOffsetManager.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/27/25.
//

import SwiftUI


class ScrollOffsetManager: ObservableObject {
    // Use a separate property for drag updates to avoid triggering view updates
    private var _dragScrollOffset: CGPoint = .zero
    var dragScrollOffset: CGPoint {
        get { _dragScrollOffset }
        set {
            _dragScrollOffset = newValue
        }
    }
    
    func updateScrollOffset(_ offset: CGPoint, isDragging: Bool) {
        _dragScrollOffset = offset
    }
}
