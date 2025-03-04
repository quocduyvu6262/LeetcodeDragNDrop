//
//  HomeView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct HomeView: View {
    let categories = DataManager.loadProblems()
    
    var body: some View {
        NavigationStack {
            TextField("Type problem name...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(categories) { category in
                        NavigationLink(destination: CategoryView(category: category)) {
                            Text(category.name)
                                .font(.headline)
                                .padding(.vertical, 8)
                        }
                        Divider()
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Leetcode Prep")
    }
}

#Preview {
    HomeView()
}
