//
//  SnippetsListView.swift
//  StudyLeetcodeApp
//
//  Created by Duy Vu Quoc on 3/2/25.
//

import SwiftUI

struct SnippetsListView: View {
    let availableSnippets: [String]
    @Binding var currentSnippet: String
    
    let onDrop: (String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                FlowLayout {
                    ForEach(availableSnippets, id: \.self) { snippet in
                        CodeSnippet(code: snippet)
                        .onDrag {
                            currentSnippet = snippet
                            let dragItem = NSItemProvider(object: snippet as NSString)
                            return dragItem
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 20)
                .padding(10.0)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .overlay {
                RoundedRectangle(cornerRadius: 12.0)
                    .stroke(Color.primary.opacity(1.0), lineWidth: 2)
            }
            .onDrop(of: [.text], delegate: SnippetsListDropDelegate (
                onDrop: onDrop
            ))
        }
    }
}

struct SnippetsListDropDelegate: DropDelegate {
    let onDrop: (String) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [.text]).first else {
            return false
        }
        
        itemProvider.loadObject(ofClass: NSString.self) { (object, error) in
            if let snippet = object as? String {
                DispatchQueue.main.async {
                    onDrop(snippet)
                }
            }
        }
        
        return true
    }
    
}
