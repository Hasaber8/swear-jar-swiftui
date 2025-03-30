//
//  UserSettingsViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing user settings-related data and operations
class UserSettingsViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var userSettings: UserSettings?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userSettingsService: UserSettingsService
    private var userId: Int?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    /// Initialize with optional user ID
    /// - Parameters:
    ///   - userId: Optional user ID to load settings for
    ///   - userSettingsService: Service for user settings operations
    init(userId: Int? = nil, userSettingsService: UserSettingsService = UserSettingsService()) {
        self.userSettingsService = userSettingsService
        self.userId = userId
        
        // If user ID is provided, fetch settings
        if let userId = userId {
            fetchUserSettings(userId: userId)
        }
    }
    
    /// Set the active user and fetch their settings
    /// - Parameter userId: The ID of the user to load settings for
    func setActiveUser(userId: Int) {
        self.userId = userId
        fetchUserSettings(userId: userId)
    }
    
    // MARK: - Settings Management
    
    /// Fetch user settings by user ID
    /// - Parameter userId: The ID of the user to retrieve settings for
    func fetchUserSettings(userId: Int) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let settings = self.userSettingsService.getUserSettings(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let settings = settings {
                    self.userSettings = settings
                } else {
                    self.errorMessage = "Failed to load user settings"
                }
            }
        }
    }
    
    /// Update notification settings for a user
    /// - Parameter enabled: Whether notifications should be enabled
    func updateNotificationSettings(enabled: Bool) {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.updateNotificationSettings(userId: userId, enabled: enabled)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings?.notificationsEnabled = enabled
                } else {
                    self.errorMessage = "Failed to update notification settings"
                }
            }
        }
    }
    
    /// Update dark mode setting for a user
    /// - Parameter enabled: Whether dark mode should be enabled
    func updateDarkMode(enabled: Bool) {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.updateDarkMode(userId: userId, enabled: enabled)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings?.darkMode = enabled
                } else {
                    self.errorMessage = "Failed to update dark mode setting"
                }
            }
        }
    }
    
    /// Update reminder time for a user
    /// - Parameter time: The reminder time in HH:MM format, or nil to disable reminders
    func updateReminderTime(time: String?) {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.updateReminderTime(userId: userId, time: time)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings?.reminderTime = time
                } else {
                    self.errorMessage = "Failed to update reminder time"
                }
            }
        }
    }
    
    /// Update share stats setting for a user
    /// - Parameter enabled: Whether sharing stats should be enabled
    func updateShareStats(enabled: Bool) {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.updateShareStats(userId: userId, enabled: enabled)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings?.shareStats = enabled
                } else {
                    self.errorMessage = "Failed to update share stats setting"
                }
            }
        }
    }
    
    /// Update auto location setting for a user
    /// - Parameter enabled: Whether auto location should be enabled
    func updateAutoLocation(enabled: Bool) {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.updateAutoLocation(userId: userId, enabled: enabled)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings?.autoLocation = enabled
                } else {
                    self.errorMessage = "Failed to update auto location setting"
                }
            }
        }
    }
    
    /// Reset all settings to default values
    func resetToDefaults() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        
        // Create default settings
        let defaultSettings = UserSettings(
            userId: userId,
            notificationsEnabled: true,
            darkMode: true,
            reminderTime: nil,
            shareStats: false,
            autoLocation: false
        )
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.userSettingsService.update(defaultSettings)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.userSettings = defaultSettings
                } else {
                    self.errorMessage = "Failed to reset settings to defaults"
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }
}
