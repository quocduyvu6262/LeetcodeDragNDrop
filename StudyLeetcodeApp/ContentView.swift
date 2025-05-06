//
//  ContentView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var snippetHistoryManager = SnippetHistoryManager()
    
    var body: some View {
        HomeView()
            .environmentObject(snippetHistoryManager)
    }
}

#Preview {
    ContentView()
}
