//
//  SnippetHistoryManager.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 5/5/25.
//

import Foundation

class SnippetHistoryManager: ObservableObject {
    var histories: [String: SnippetHistory] = [:]

    func history(for problem: Problem) -> SnippetHistory {
        let key = problem.name
        if let existing = histories[key] {
            return existing
        } else {
            let newHistory = SnippetHistory()
            histories[key] = newHistory
            return newHistory
        }
    }
}
