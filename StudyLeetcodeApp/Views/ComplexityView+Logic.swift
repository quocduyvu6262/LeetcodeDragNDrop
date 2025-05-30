//
//  ComplexityView+Logic.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/5/25.
//

import Foundation

extension ComplexityView {
    func isCorrectComplexity() -> Bool {
        return selectedTimeComplexity == problem.correctTimeComplexity &&
               selectedSpaceComplexity == problem.correctSpaceComplexity
    }
}
