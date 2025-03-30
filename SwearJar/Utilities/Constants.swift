//
//  Constants.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import SwiftUI

/// App-wide constants
struct Constants {
    // MARK: - App Information
    
    /// App name
    static let appName = "SwearJar"
    
    /// App version
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // MARK: - Database
    
    /// Database filename
    static let databaseFilename = "swearjar.sqlite"
    
    // MARK: - UI Constants
    
    /// Standard corner radius for UI elements
    static let cornerRadius: CGFloat = 12.0
    
    /// Standard padding for UI elements
    static let padding: CGFloat = 16.0
    
    /// Small padding for UI elements
    static let smallPadding: CGFloat = 8.0
    
    /// Animation duration
    static let animationDuration: Double = 0.3
    
    // MARK: - Colors
    
    /// Primary app color
    static let primaryColor = Color("PrimaryColor")
    
    /// Secondary app color
    static let secondaryColor = Color("SecondaryColor")
    
    /// Text color for light mode
    static let textColor = Color("TextColor")
    
    /// Background color
    static let backgroundColor = Color("BackgroundColor")
    
    /// Error color
    static let errorColor = Color.red
    
    /// Success color
    static let successColor = Color.green
    
    // MARK: - Fonts
    
    /// Title font
    static let titleFont = Font.system(.title, design: .rounded).weight(.bold)
    
    /// Heading font
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    
    /// Body font
    static let bodyFont = Font.system(.body, design: .rounded)
    
    /// Caption font
    static let captionFont = Font.system(.caption, design: .rounded)
    
    // MARK: - Default Values
    
    /// Default fine amount
    static let defaultFine: Double = 1.00
    
    /// Default currency symbol
    static let defaultCurrencySymbol = "$"
    
    /// Default notification time (8 PM)
    static let defaultReminderTime: Date = {
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    // MARK: - User Defaults Keys
    
    struct UserDefaultsKeys {
        /// Current user ID
        static let currentUserId = "currentUserId"
        
        /// Whether onboarding has been completed
        static let onboardingCompleted = "onboardingCompleted"
        
        /// Last backup date
        static let lastBackupDate = "lastBackupDate"
    }
    
    // MARK: - Notification Names
    
    struct NotificationNames {
        /// Notification when user logs a swear
        static let didLogSwear = Notification.Name("didLogSwear")
        
        /// Notification when user settings change
        static let didChangeSettings = Notification.Name("didChangeSettings")
        
        /// Notification when streak changes
        static let didChangeStreak = Notification.Name("didChangeStreak")
    }
    
    // MARK: - Swear Categories
    
    /// Predefined categories for swear words
    static let swearCategories = [
        "Mild",
        "Medium",
        "Strong",
        "Very Strong",
        "Religious",
        "Slur"
    ]
    
    // MARK: - URLs
    
    struct URLs {
        /// Privacy policy URL - dummy
        static let privacyPolicy = URL(string: "https://example.com/privacy")!
        
        /// Terms of service URL
        static let termsOfService = URL(string: "https://example.com/terms")!
        
        /// Help and support URL
        static let support = URL(string: "https://example.com/support")!
    }
}