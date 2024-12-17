//
//  SearchBarView.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//

import Foundation
import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    let productCount: Int
    let placeholder: String
    @FocusState private var isFocused: Bool
    
    init(text: Binding<String>,
         productCount: Int,
         placeholder: String = "Search products") {
        self._text = text
        self.productCount = productCount
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Search Field
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                        .submitLabel(.search)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // Clear button without animation
                    if !text.isEmpty {
                        Button {
                            text = ""
                            isFocused = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Product Count
            HStack {
                Text("\(productCount) Product\(productCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
    }
}

// MARK: - Preview
struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Empty State
            SearchBarView(
                text: .constant(""),
                productCount: 0
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Empty")
            
            // With Text
            SearchBarView(
                text: .constant("test"),
                productCount: 5,
                placeholder: "Search favorites"
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("With Text")
            
            // Dark Mode
            SearchBarView(
                text: .constant(""),
                productCount: 10
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
