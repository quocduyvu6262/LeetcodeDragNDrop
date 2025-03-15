//
//  HomeView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct HomeView: View {
    let categories = DataManager.loadProblems()
    
    @State private var searchText: String = ""
    
    private var filteredCategory: [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { category in
                category.name.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            TextField("Search category...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(filteredCategory) { category in
                        NavigationLink(destination: ProblemsListView(category: category)) {
                            CategoryCard(category: category)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Leetcode Prep")
    }
}

#Preview {
    HomeView()
}
