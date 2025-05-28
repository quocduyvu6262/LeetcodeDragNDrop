//
//  Constants.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import Foundation
import SwiftUI

public enum Constants {
    // Canvas
    public static let dotSpacing: CGFloat = 16
    public static let snippetSpacing: CGFloat = dotSpacing * 2 - snippetHeight
    public static let indentDefault: Int = 2
    public static let canvasHeightFactor: CGFloat = 0.68
    public static let minCanvasHeightFactor: CGFloat = 1.1
    
    // Snippet
    public static let snippetFont: UIFont = UIFont(name: "JetBrainsMono-Regular", size: 12) ?? UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
    public static let snippetHeight: CGFloat = 26
}
