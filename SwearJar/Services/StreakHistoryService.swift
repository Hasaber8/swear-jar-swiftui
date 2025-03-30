//
//  StreakHistoryService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing streak history-related operations
class StreakHistoryService {
    
    // MARK: - Properties
    
    private let streakHistoryRepository: StreakHistoryRepository
    
    // MARK: - Initialization
    
    init(streakHistoryRepository: StreakHistoryRepository = StreakHistoryRepository()) {
        self.streakHistoryRepository = streakHistoryRepository
    }
    
    // MARK: - Streak Management
    
    /// Start a new streak for a user
    /// - Parameter userId: The user ID to start a streak for
    /// - Returns: The new streak history, or nil if there was an error
    func startNewStreak(userId: Int) -> StreakHistory? {
        return streakHistoryRepository.startNewStreak(userId: userId)
    }
    
    /// End the current streak for a user
    /// - Parameter userId: The user ID to end the streak for
    /// - Returns: True if a streak was ended, false if no current streak exists or if there was an error
    func endCurrentStreak(userId: Int) -> Bool {
        return streakHistoryRepository.endCurrentStreak(userId: userId)
    }
    
    /// Increment the current streak length by 1
    /// - Parameter userId: The user ID to increment the streak for
    /// - Returns: The updated streak history, or a new streak if no current streak exists, nil if there was an error
    func incrementStreak(userId: Int) -> StreakHistory? {
        return streakHistoryRepository.incrementStreak(userId: userId)
    }
    
    // MARK: - Analytics
    
    /// Get the user's longest streak
    /// - Parameter userId: The user ID to get the longest streak for
    /// - Returns: The longest streak history, or nil if no streaks exist or if there was an error
    func getLongestStreak(userId: Int) -> StreakHistory? {
        return streakHistoryRepository.getLongestStreak(userId: userId)
    }
    
    /// Check if a user has an active streak
    /// - Parameter userId: The user ID to check
    /// - Returns: True if the user has an active streak, false otherwise
    func hasActiveStreak(userId: Int) -> Bool {
        return streakHistoryRepository.hasActiveStreak(userId: userId)
    }
    
    /// Get all streak histories for a user
    /// - Parameter userId: The user ID to get streak histories for
    /// - Returns: Array of streak histories, empty array if none or if there was an error
    func getAllForUser(userId: Int) -> [StreakHistory] {
        return streakHistoryRepository.getAllForUser(userId: userId)
    }
    
    /// Get the current active streak for a user
    /// - Parameter userId: The user ID to get the current streak for
    /// - Returns: The current streak if one exists, nil otherwise
    func getCurrentStreak(userId: Int) -> StreakHistory? {
        return streakHistoryRepository.getCurrentStreak(userId: userId)
    }
}
