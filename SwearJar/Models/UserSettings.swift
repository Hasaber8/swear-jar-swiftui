//
//  UserSettings.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a user's app settings and preferences
struct UserSettings: Identifiable, Codable {
    /// Database ID for the settings entry
    var id: Int?
    
    /// Reference to the user these settings belong to
    var userId: Int
    
    /// Whether push notifications are enabled
    var notificationsEnabled: Bool
    
    /// Whether dark mode is enabled
    var darkMode: Bool
    
    /// Time of day for daily reminders (HH:MM format)
    var reminderTime: String?
    
    /// Whether to share anonymized stats
    var shareStats: Bool
    
    /// Whether to automatically capture location
    var autoLocation: Bool
    
    /// Creates a new UserSettings instance with default values
    init(id: Int? = nil,
         userId: Int,
         notificationsEnabled: Bool = true,
         darkMode: Bool = true,
         reminderTime: String? = nil,
         shareStats: Bool = false,
         autoLocation: Bool = false) {
        
        self.id = id
        self.userId = userId
        self.notificationsEnabled = notificationsEnabled
        self.darkMode = darkMode
        self.reminderTime = reminderTime
        self.shareStats = shareStats
        self.autoLocation = autoLocation
    }
    
    /// Database table name for the UserSettings model
    static let tableName = "user_settings"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "setting_id"
        case userId = "user_id"
        case notificationsEnabled = "notifications_enabled"
        case darkMode = "dark_mode"
        case reminderTime = "reminder_time"
        case shareStats = "share_stats"
        case autoLocation = "auto_location"
    }
}

// MARK: - GRDB Extensions
extension UserSettings: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        userId = row[CodingKeys.userId.stringValue] as Int
        notificationsEnabled = row[CodingKeys.notificationsEnabled.stringValue] as Bool
        darkMode = row[CodingKeys.darkMode.stringValue] as Bool
        reminderTime = row[CodingKeys.reminderTime.stringValue] as String?
        shareStats = row[CodingKeys.shareStats.stringValue] as Bool
        autoLocation = row[CodingKeys.autoLocation.stringValue] as Bool
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.userId.stringValue] = userId
        container[CodingKeys.notificationsEnabled.stringValue] = notificationsEnabled
        container[CodingKeys.darkMode.stringValue] = darkMode
        container[CodingKeys.reminderTime.stringValue] = reminderTime
        container[CodingKeys.shareStats.stringValue] = shareStats
        container[CodingKeys.autoLocation.stringValue] = autoLocation
        
        // Only include id for updates, not inserts
        if let id = id {
            container[CodingKeys.id.stringValue] = id
        }
    }
    
    /// Update the id after a successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = Int(inserted.rowID)
    }
}
