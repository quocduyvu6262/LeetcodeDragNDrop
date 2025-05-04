//
//  StudyLeetcodeAppApp.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI
import SwiftData

@main
struct StudyLeetcodeAppApp: App {
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DroppedSnippet.self])
    }
}
