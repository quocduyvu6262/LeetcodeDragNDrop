//
//  Category.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import Foundation

struct Category: Codable, Identifiable {
    let id = UUID()
    let name: String
    var problems: [Problem]
}
