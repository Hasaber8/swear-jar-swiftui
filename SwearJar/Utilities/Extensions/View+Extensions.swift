//
//  View+Extensions.swift
//  SwearJar
//
//  Created for SwearJar app
//

import SwiftUI

extension View {
    /// Apply standard corner radius from Constants
    func standardCornerRadius() -> some View {
        self.cornerRadius(Constants.cornerRadius)
    }
    
    /// Apply standard shadow
    func standardShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    /// Apply conditional modifier
    /// - Parameters:
    ///   - condition: Condition to check
    ///   - transform: Transform to apply if condition is true
    /// - Returns: Modified view if condition is true, otherwise original view
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Hide keyboard when tapping outside of a text field
    func hideKeyboardWhenTappedAround() -> some View {
        return self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    /// Apply loading overlay
    /// - Parameter isLoading: Whether loading is in progress
    /// - Returns: View with loading overlay if isLoading is true
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            ZStack {
                if isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
            }
        )
        .disabled(isLoading)
    }
}