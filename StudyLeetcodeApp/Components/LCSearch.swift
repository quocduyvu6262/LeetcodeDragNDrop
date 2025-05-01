//
//  LCSearch.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 4/30/25.
//

import SwiftUI

struct LCSearch: View {
    @Binding var searchText: String
    var title: String?
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(title ?? "Search category...", text: $searchText)
                .foregroundColor(.primary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(12)
        .background(Color(.systemGray5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
