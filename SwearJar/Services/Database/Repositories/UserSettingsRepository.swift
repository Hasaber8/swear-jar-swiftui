//
//  UserSettingsRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing UserSettings entities in the database
class UserSettingsRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create settings for a user
    /// - Parameter settings: The settings to create
    /// - Returns: The created settings with ID assigned, or nil if creation failed
    func create(_ settings: UserSettings) -> UserSettings? {
        do {
            var newSettings = settings
            try dbQueue.write { db in
                try newSettings.insert(db)
            }
            return newSettings
        } catch {
            print("Error creating user settings: \(error)")
            return nil
        }
    }
    
    /// Retrieve settings by ID
    /// - Parameter id: The ID of the settings to retrieve
    /// - Returns: The settings if found, nil otherwise
    func getById(_ id: Int) -> UserSettings? {
        do {
            return try dbQueue.read { db in
                try UserSettings.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching settings by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve settings for a specific user
    /// - Parameter userId: The user ID to get settings for
    /// - Returns: The settings if found, nil otherwise
    func getByUserId(_ userId: Int) -> UserSettings? {
        do {
            return try dbQueue.read { db in
                try UserSettings
                    .filter(Column(UserSettings.CodingKeys.userId.stringValue) == userId)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching settings by user ID: \(error)")
            return nil
        }
    }
    
    /// Update existing settings
    /// - Parameter settings: The settings to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ settings: UserSettings) -> Bool {
        guard settings.id != nil else {
            print("Error updating settings: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try settings.update(db)
            }
            return true
        } catch {
            print("Error updating settings: \(error)")
            return false
        }
    }
    
    /// Delete settings by ID
    /// - Parameter id: The ID of the settings to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try UserSettings.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting settings: \(error)")
            return false
        }
    }
    
    /// Delete settings for a specific user
    /// - Parameter userId: The user ID to delete settings for
    /// - Returns: True if the deletion was successful, false otherwise
    func deleteByUserId(_ userId: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try UserSettings
                    .filter(Column(UserSettings.CodingKeys.userId.stringValue) == userId)
                    .deleteAll(db)
            }
            return true
        } catch {
            print("Error deleting settings by user ID: \(error)")
            return false
        }
    }
    
    // MARK: - Additional Methods
    
    /// Get or create settings for a user
    /// - Parameter userId: The user ID to get or create settings for
    /// - Returns: The settings, or nil if there was an error
    func getOrCreate(userId: Int) -> UserSettings? {
        // Try to get existing settings
        if let settings = getByUserId(userId) {
            return settings
        }
        
        // Create default settings if none exist
        let defaultSettings = UserSettings(
            userId: userId,
            notificationsEnabled: true,
            darkMode: true,
            reminderTime: nil,
            shareStats: false,
            autoLocation: false
        )
        
        return create(defaultSettings)
    }
    
    /// Update notification settings
    /// - Parameters:
    ///   - userId: The user ID to update settings for
    ///   - enabled: Whether notifications should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateNotifications(userId: Int, enabled: Bool) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: """
                    UPDATE \(UserSettings.databaseTableName)
                    SET \(UserSettings.CodingKeys.notificationsEnabled.stringValue) = ?
                    WHERE \(UserSettings.CodingKeys.userId.stringValue) = ?
                    """,
                    arguments: [enabled, userId]
                )
            }
            return true
        } catch {
            print("Error updating notification settings: \(error)")
            return false
        }
    }
    
    /// Update dark mode setting
    /// - Parameters:
    ///   - userId: The user ID to update settings for
    ///   - enabled: Whether dark mode should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateDarkMode(userId: Int, enabled: Bool) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: """
                    UPDATE \(UserSettings.databaseTableName)
                    SET \(UserSettings.CodingKeys.darkMode.stringValue) = ?
                    WHERE \(UserSettings.CodingKeys.userId.stringValue) = ?
                    """,
                    arguments: [enabled, userId]
                )
            }
            return true
        } catch {
            print("Error updating dark mode setting: \(error)")
            return false
        }
    }
    
    /// Update reminder time
    /// - Parameters:
    ///   - userId: The user ID to update settings for
    ///   - time: The reminder time in HH:MM format, or nil to disable reminders
    /// - Returns: True if the update was successful, false otherwise
    func updateReminderTime(userId: Int, time: String?) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: """
                    UPDATE \(UserSettings.databaseTableName)
                    SET \(UserSettings.CodingKeys.reminderTime.stringValue) = ?
                    WHERE \(UserSettings.CodingKeys.userId.stringValue) = ?
                    """,
                    arguments: [time, userId]
                )
            }
            return true
        } catch {
            print("Error updating reminder time: \(error)")
            return false
        }
    }
}
