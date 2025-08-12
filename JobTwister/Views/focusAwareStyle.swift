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
    @Environment(\.colorScheme) var colorScheme
    
    private func getTextColor() -> Color {
        if isFocused {
            return colorScheme == .light ? .black : .black
        } else {
            return colorScheme == .light ? .black : .white
        }
    }
    
    private func getBackgroundColor() -> Color {
        if isFocused {
            return colorScheme == .light ? .white : .white
        } else {
            return .clear
        }
    }
    
    func body(content: Content) -> some View {
        content
            .textFieldStyle(.plain)
            .focused($isFocused)
            .padding(.horizontal, 4)  
            .padding(.vertical, 2)
            .foregroundStyle(getTextColor())
            .tint(.accentColor)
            .background(
                RoundedRectangle(cornerRadius: 4)     // Smaller corner radius
                    .fill(getBackgroundColor())
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isFocused ? Color.accentColor : Color.clear)
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
