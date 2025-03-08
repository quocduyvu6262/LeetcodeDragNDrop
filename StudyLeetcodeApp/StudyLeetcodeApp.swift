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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DroppedSnippet.self])
    }
}
