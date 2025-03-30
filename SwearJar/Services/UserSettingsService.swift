//
//  UserSettingsService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing user settings-related operations
class UserSettingsService {
    
    // MARK: - Properties
    
    private let userSettingsRepository: UserSettingsRepository
    
    // MARK: - Initialization
    
    init(userSettingsRepository: UserSettingsRepository = UserSettingsRepository()) {
        self.userSettingsRepository = userSettingsRepository
    }
    
    // MARK: - Settings Management
    
    /// Update notification settings for a user
    /// - Parameters:
    ///   - userId: The ID of the user to update settings for
    ///   - enabled: Whether notifications should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateNotificationSettings(userId: Int, enabled: Bool) -> Bool {
        return userSettingsRepository.updateNotifications(userId: userId, enabled: enabled)
    }
    
    /// Update dark mode setting for a user
    /// - Parameters:
    ///   - userId: The ID of the user to update settings for
    ///   - enabled: Whether dark mode should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateDarkMode(userId: Int, enabled: Bool) -> Bool {
        return userSettingsRepository.updateDarkMode(userId: userId, enabled: enabled)
    }
    
    /// Update reminder time for a user
    /// - Parameters:
    ///   - userId: The ID of the user to update settings for
    ///   - time: The reminder time in HH:MM format, or nil to disable reminders
    /// - Returns: True if the update was successful, false otherwise
    func updateReminderTime(userId: Int, time: String?) -> Bool {
        guard var settings = userSettingsRepository.getByUserId(userId) else {
            return false
        }
        
        settings.reminderTime = time
        return userSettingsRepository.update(settings)
    }
    
    /// Update share stats setting for a user
    /// - Parameters:
    ///   - userId: The ID of the user to update settings for
    ///   - enabled: Whether share stats should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateShareStats(userId: Int, enabled: Bool) -> Bool {
        guard var settings = userSettingsRepository.getByUserId(userId) else {
            return false
        }
        
        settings.shareStats = enabled
        return userSettingsRepository.update(settings)
    }
    
    /// Update auto location setting for a user
    /// - Parameters:
    ///   - userId: The ID of the user to update settings for
    ///   - enabled: Whether auto location should be enabled
    /// - Returns: True if the update was successful, false otherwise
    func updateAutoLocation(userId: Int, enabled: Bool) -> Bool {
        guard var settings = userSettingsRepository.getByUserId(userId) else {
            return false
        }
        
        settings.autoLocation = enabled
        return userSettingsRepository.update(settings)
    }
    
    /// Update the entire settings object
    /// - Parameter settings: The settings object to update
    /// - Returns: True if the update was successful, false otherwise
    func update(_ settings: UserSettings) -> Bool {
        return userSettingsRepository.update(settings)
    }
    
    /// Get user settings by user ID
    /// - Parameter userId: The ID of the user to retrieve settings for
    /// - Returns: The user settings if found, nil otherwise
    func getUserSettings(userId: Int) -> UserSettings? {
        return userSettingsRepository.getByUserId(userId)
    }
    
    /// Get reminder time for a user
    /// - Parameter userId: The ID of the user to retrieve reminder time for
    /// - Returns: The reminder time in HH:MM format, or nil if reminders are disabled
    func getReminderTime(userId: Int) -> String? {
        guard let settings = userSettingsRepository.getByUserId(userId) else {
            return nil
        }
        
        return settings.reminderTime
    }
    
    /// Get share stats setting for a user
    /// - Parameter userId: The ID of the user to retrieve share stats setting for
    /// - Returns: Whether share stats are enabled
    func getShareStats(userId: Int) -> Bool {
        guard let settings = userSettingsRepository.getByUserId(userId) else {
            return false
        }
        
        return settings.shareStats
    }
    
    /// Get auto location setting for a user
    /// - Parameter userId: The ID of the user to retrieve auto location setting for
    /// - Returns: Whether auto location is enabled
    func getAutoLocation(userId: Int) -> Bool {
        guard let settings = userSettingsRepository.getByUserId(userId) else {
            return false
        }
        
        return settings.autoLocation
    }
}
