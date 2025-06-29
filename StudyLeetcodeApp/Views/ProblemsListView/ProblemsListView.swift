//
//  CategoryView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 2/27/25.
//

import SwiftUI

struct ProblemsListView: View {
    let category: Category
    
    @StateObject private var viewModel: ProblemsListViewModel
    let onUpdate: (String, Int) -> Void
    
    init(category: Category, onUpdate: @escaping (String, Int) -> Void) {
        self.category = category
        _viewModel = StateObject(wrappedValue: ProblemsListViewModel(category: category))
        self.onUpdate = onUpdate
    }
    
    
    var body: some View {
        VStack {
            LCSearch(searchText: $viewModel.searchText, title: "Search problems")
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(viewModel.filteredProblems) { problem in
                        NavigationLink(destination: DescriptionView(problem: problem, nextStep: {})) {
                            ProblemCard(problem: problem)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        LCButton(
                            title: "Download More Problems",
                            font: .subheadline
                        ) {
                            viewModel.loadMoreProblems(for: category.name) { count in
                                self.onUpdate(category.name, count)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle(category.name)
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: alertItem.title,
                message: alertItem.message,
                dismissButton: alertItem.dismissButton
            )
        }
    }
}

//#Preview {
//    @State var step: Int = 0
//    let sampleProblem = Problem(
//        name: "Two Sum",
//        difficulty: "Easy",
//        description: "Given [2, 7, 11, 15] and target 9, find two numbers that add up.",
//        snippets: [
//            "hashmap = {}",
//            "for num in array:",
//            "if target - num in hashmap:",
//            "return [num, hashmap[target - num]]",
//            "hashmap[num] = num",
//            "for i in array: for j in array:",
//            "sort(array)"
//          ],
//        function: "def twoSum(array, target)",
//        inputs: ["[2,7,11,15,19], 9"],
//        outputs: ["[7, 2]"],
//        timeComplexityOptions: ["O(n²)", "O(n)", "O(n log n)", "O(1)"],
//        spaceComplexityOptions: ["O(1)", "O(n)", "O(2\u{207F})", "O(n!)"],
//        correctTimeComplexity: "O(n)",
//        correctSpaceComplexity: "O(n)"
//    )
//    
//    let sampleCategory = Category(name: "Two Pointer", problems: [sampleProblem])
//    
//    return NavigationStack {
//        ProblemsListView(category: sampleCategory) { name, count in
//            print("onUpdate")
//        }
//    }
//}

