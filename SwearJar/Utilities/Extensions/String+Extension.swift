//
//  String+Extensions.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

extension String {
    /// Check if string is empty or contains only whitespace
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Capitalize first letter only
    var capitalizedFirstLetter: String {
        guard !isEmpty else { return self }
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Get initials (up to 2 characters)
    var initials: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        let validComponents = components.filter { !$0.isEmpty }
        
        if validComponents.isEmpty {
            return ""
        } else if validComponents.count == 1 {
            return String(validComponents[0].prefix(1)).uppercased()
        } else {
            let first = validComponents[0].prefix(1)
            let last = validComponents[validComponents.count - 1].prefix(1)
            return (first + last).uppercased()
        }
    }
    
    /// Check if string is a valid email address
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    /// Convert string to URL if possible
    var asURL: URL? {
        return URL(string: self)
    }
}