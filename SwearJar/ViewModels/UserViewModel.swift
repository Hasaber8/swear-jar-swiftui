//
//  UserViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing user-related data and operations
class UserViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var user: User?
    @Published var totalSwears: Int = 0
    @Published var totalFines: Double = 0.0
    
    private let userService: UserService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(userService: UserService = UserService()) {
        self.userService = userService
    }
    
    // MARK: - User Operations
    
    /// Create a new user
    /// - Parameters:
    ///   - username: The username for the new user
    ///   - displayName: The display name for the new user
    func createUser(username: String, displayName: String) {
        if let newUser = userService.createUser(username: username, displayName: displayName) {
            self.user = newUser
            fetchUserStatistics(userId: newUser.id!)
        } else {
            print("Failed to create user.")
        }
    }
    
    /// Update the display name of the user
    /// - Parameter newDisplayName: The new display name
    func updateDisplayName(newDisplayName: String) {
        guard let userId = user?.id else { return }
        if userService.updateDisplayName(userId: userId, newDisplayName: newDisplayName) {
            user?.displayName = newDisplayName
        } else {
            print("Failed to update display name.")
        }
    }
    
    /// Fetch user details by ID
    /// - Parameter userId: The ID of the user to fetch
    func fetchUserDetails(userId: Int) {
        if let fetchedUser = userService.getUserDetails(userId: userId) {
            self.user = fetchedUser
            fetchUserStatistics(userId: userId)
        } else {
            print("User not found.")
        }
    }
    
    // MARK: - Statistics
    
    /// Fetch user statistics
    /// - Parameter userId: The ID of the user to fetch statistics for
    private func fetchUserStatistics(userId: Int) {
        if let stats = userService.getUserStatistics(userId: userId) {
            self.totalSwears = stats.totalSwears
            self.totalFines = stats.totalFines
        } else {
            print("Failed to fetch user statistics.")
        }
    }
    
    // MARK: - Extended Functionality
    
    /// Check if a username is already taken
    /// - Parameter username: The username to check
    /// - Returns: True if the username is taken, false otherwise
    func isUsernameTaken(_ username: String) -> Bool {
        return userService.isUsernameTaken(username)
    }
    
    /// Get a user by username
    /// - Parameter username: The username to search for
    /// - Returns: The user if found, nil otherwise
    func getUserByUsername(_ username: String) -> User? {
        return userService.getUserByUsername(username)
    }
    
    /// Get all users in the system
    /// - Returns: Array of all users
    func getAllUsers() -> [User] {
        return userService.getAllUsers()
    }
    
    /// Delete the current user
    /// - Returns: True if deletion was successful, false otherwise
    func deleteCurrentUser() -> Bool {
        guard let userId = user?.id else { return false }
        let success = userService.deleteUser(userId: userId)
        if success {
            self.user = nil
            self.totalSwears = 0
            self.totalFines = 0.0
        }
        return success
    }
    
    /// Reset the current user's statistics
    /// - Returns: True if reset was successful, false otherwise
    func resetStatistics() -> Bool {
        guard let userId = user?.id else { return false }
        let success = userService.resetUserStatistics(userId: userId)
        if success {
            self.totalSwears = 0
            self.totalFines = 0.0
            self.user?.totalSwears = 0
            self.user?.totalFine = 0
        }
        return success
    }
    
    /// Increment the user's swear count and fine total
    /// - Parameter fineAmount: The fine amount to add
    /// - Returns: True if the update was successful, false otherwise
    func incrementSwearStats(fineAmount: Double) -> Bool {
        guard let userId = user?.id else { return false }
        let success = userService.incrementSwearStats(userId: userId, fineAmount: fineAmount)
        if success {
            self.totalSwears += 1
            self.totalFines += fineAmount
            self.user?.totalSwears += 1
            self.user?.totalFine += fineAmount
        }
        return success
    }
}
