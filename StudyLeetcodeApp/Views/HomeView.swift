//
//  HomeView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var searchText: String
    @State private var categories: [Category]
    @State private var problemCounts: Dictionary<String, Int>
    
    init() {
        _searchText = State(initialValue: "")
        _categories = State(initialValue: DataManager.loadCategories())
        _problemCounts = State(initialValue: [:])
    }
    
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
            
            Text("Leetcode Prep")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LCSearch(searchText: $searchText)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(filteredCategory) { category in
                        NavigationLink(destination: ProblemsListView(category: category) { categoryName, count in
                            problemCounts[categoryName] = count
                        }) {
                            CategoryCard(category: category, problemCount: problemCounts[category.name] ?? 0)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Leetcode Prep")
        .onAppear {
            for category in self.categories {
                _problemCounts.wrappedValue[category.name] = category.problems.count
            }
        }
    }
}

#Preview {
    HomeView()
}
