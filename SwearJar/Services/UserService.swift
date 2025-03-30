//
//  UserService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing user-related operations
class UserService {
    
    // MARK: - Properties
    
    private let userRepository: UserRepository
    private let userSettingsRepository: UserSettingsRepository
    
    // MARK: - Initialization
    
    init(userRepository: UserRepository = UserRepository(),
         userSettingsRepository: UserSettingsRepository = UserSettingsRepository()) {
        self.userRepository = userRepository
        self.userSettingsRepository = userSettingsRepository
    }
    
    // MARK: - User Operations
    
    /// Create a new user with default settings
    /// - Parameters:
    ///   - username: The username for the new user
    ///   - displayName: The display name for the new user
    /// - Returns: The created user, or nil if creation failed
    func createUser(username: String, displayName: String) -> User? {
        // Check if username is already taken
        guard !userRepository.isUsernameTaken(username) else {
            print("Username is already taken.")
            return nil
        }
        
        // Create a new user
        let newUser = User(username: username, displayName: displayName)
        guard let createdUser = userRepository.create(newUser) else {
            print("Failed to create user.")
            return nil
        }
        
        // Create default settings for the user
        let defaultSettings = UserSettings(userId: createdUser.id!)
        guard userSettingsRepository.create(defaultSettings) != nil else {
            print("Failed to create user settings.")
            return nil
        }
        
        return createdUser
    }
    
    /// Update the display name of a user
    /// - Parameters:
    ///   - userId: The ID of the user to update
    ///   - newDisplayName: The new display name
    /// - Returns: True if the update was successful, false otherwise
    func updateDisplayName(userId: Int, newDisplayName: String) -> Bool {
        guard var user = userRepository.getById(userId) else {
            print("User not found.")
            return false
        }
        
        user.displayName = newDisplayName
        return userRepository.update(user)
    }
    
    /// Get user details by ID
    /// - Parameter userId: The ID of the user to retrieve
    /// - Returns: The user if found, nil otherwise
    func getUserDetails(userId: Int) -> User? {
        return userRepository.getById(userId)
    }
    
    // MARK: - Statistics Management
    
    /// Increment the user's swear count and fine total
    /// - Parameters:
    ///   - userId: The ID of the user to update
    ///   - fineAmount: The fine amount to add
    /// - Returns: True if the update was successful, false otherwise
    func incrementSwearStats(userId: Int, fineAmount: Double) -> Bool {
        return userRepository.incrementSwearStats(userId: userId, fineAmount: fineAmount)
    }
    
    /// Get the total swears and fines for a user
    /// - Parameter userId: The ID of the user to retrieve statistics for
    /// - Returns: A tuple containing total swears and total fines, or nil if there was an error
    func getUserStatistics(userId: Int) -> (totalSwears: Int, totalFines: Double)? {
        guard let user = userRepository.getById(userId) else {
            print("User not found.")
            return nil
        }
        
        return (totalSwears: user.totalSwears, totalFines: user.totalFine)
    }
    
    /// Get a user by username
    /// - Parameter username: The username to search for
    /// - Returns: The user if found, nil otherwise
    func getUserByUsername(_ username: String) -> User? {
        return userRepository.getByUsername(username)
    }
    
    /// Check if a username is already taken
    /// - Parameter username: The username to check
    /// - Returns: True if the username is taken, false otherwise
    func isUsernameTaken(_ username: String) -> Bool {
        return userRepository.isUsernameTaken(username)
    }
    
    /// Get all users in the system
    /// - Returns: Array of all users, empty array if none or if there was an error
    func getAllUsers() -> [User] {
        return userRepository.getAll()
    }
    
    /// Delete a user by ID
    /// - Parameter userId: The ID of the user to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func deleteUser(userId: Int) -> Bool {
        // First delete user settings to maintain referential integrity
        _ = userSettingsRepository.deleteByUserId(userId)
        
        // Then delete the user
        return userRepository.delete(id: userId)
    }
    
    /// Reset a user's statistics
    /// - Parameter userId: The ID of the user to reset statistics for
    /// - Returns: True if the reset was successful, false otherwise
    func resetUserStatistics(userId: Int) -> Bool {
        guard var user = userRepository.getById(userId) else {
            print("User not found.")
            return false
        }
        
        user.totalSwears = 0
        user.totalFine = 0
        
        return userRepository.update(user)
    }
}
