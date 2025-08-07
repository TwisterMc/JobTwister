//
//  focusAwareStyle.swift
//  JobTwister
//
//  Created by Thomas on 8/7/25.
//

import SwiftUI

// Create a custom ViewModifier
struct FocusAwareStyle: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .focused($isFocused)
            .padding(.horizontal, 4)  
            .padding(.vertical, 2 )
            .background(
                RoundedRectangle(cornerRadius: 4)     // Smaller corner radius
                    .fill(isFocused ? Color.white : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isFocused ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

// Create a convenience extension
extension View {
    func focusAwareStyle() -> some View {
        modifier(FocusAwareStyle())
    }
}
