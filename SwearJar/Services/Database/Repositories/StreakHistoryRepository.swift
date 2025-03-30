//
//  StreakHistoryRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing StreakHistory entities in the database
class StreakHistoryRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new streak history record
    /// - Parameter streak: The streak history to create
    /// - Returns: The created streak history with ID assigned, or nil if creation failed
    func create(_ streak: StreakHistory) -> StreakHistory? {
        do {
            var newStreak = streak
            try dbQueue.write { db in
                try newStreak.insert(db)
            }
            return newStreak
        } catch {
            print("Error creating streak history: \(error)")
            return nil
        }
    }
    
    /// Retrieve a streak history by ID
    /// - Parameter id: The ID of the streak history to retrieve
    /// - Returns: The streak history if found, nil otherwise
    func getById(_ id: Int) -> StreakHistory? {
        do {
            return try dbQueue.read { db in
                try StreakHistory.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching streak history by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve all streak histories for a user
    /// - Parameter userId: The user ID to get streak histories for
    /// - Returns: Array of streak histories, empty array if none or if there was an error
    func getAllForUser(userId: Int) -> [StreakHistory] {
        do {
            return try dbQueue.read { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .order(Column(StreakHistory.CodingKeys.startDate.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching streak histories for user: \(error)")
            return []
        }
    }
    
    /// Get the current active streak for a user
    /// - Parameter userId: The user ID to get the current streak for
    /// - Returns: The current streak if one exists, nil otherwise
    func getCurrentStreak(userId: Int) -> StreakHistory? {
        do {
            return try dbQueue.read { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(StreakHistory.CodingKeys.isCurrent.stringValue) == true)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching current streak for user: \(error)")
            return nil
        }
    }
    
    /// Update an existing streak history
    /// - Parameter streak: The streak history to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ streak: StreakHistory) -> Bool {
        guard streak.id != nil else {
            print("Error updating streak history: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try streak.update(db)
            }
            return true
        } catch {
            print("Error updating streak history: \(error)")
            return false
        }
    }
    
    /// Delete a streak history by ID
    /// - Parameter id: The ID of the streak history to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try StreakHistory.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting streak history: \(error)")
            return false
        }
    }
    
    /// Delete all streak histories for a user
    /// - Parameter userId: The user ID to delete streak histories for
    /// - Returns: The number of streak histories deleted, or 0 if there was an error
    func deleteAllForUser(userId: Int) -> Int {
        do {
            return try dbQueue.write { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .deleteAll(db)
            }
        } catch {
            print("Error deleting streak histories for user: \(error)")
            return 0
        }
    }
    
    // MARK: - Streak Management
    
    /// Start a new streak for a user
    /// - Parameter userId: The user ID to start a streak for
    /// - Returns: The new streak history, or nil if there was an error
    func startNewStreak(userId: Int) -> StreakHistory? {
        // First, end any current streak
        endCurrentStreak(userId: userId)
        
        // Start a new streak
        let newStreak = StreakHistory(
            userId: userId,
            streakLength: 1,
            startDate: Date(),
            endDate: nil,
            isCurrent: true
        )
        
        return create(newStreak)
    }
    
    /// End the current streak for a user
    /// - Parameter userId: The user ID to end the streak for
    /// - Returns: True if a streak was ended, false if no current streak exists or if there was an error
    func endCurrentStreak(userId: Int) -> Bool {
        guard let currentStreak = getCurrentStreak(userId: userId) else {
            return false
        }
        
        var updatedStreak = currentStreak
        updatedStreak.endDate = Date()
        updatedStreak.isCurrent = false
        
        return update(updatedStreak)
    }
    
    /// Increment the current streak length by 1
    /// - Parameter userId: The user ID to increment the streak for
    /// - Returns: The updated streak history, or a new streak if no current streak exists, nil if there was an error
    func incrementStreak(userId: Int) -> StreakHistory? {
        if let currentStreak = getCurrentStreak(userId: userId) {
            var updatedStreak = currentStreak
            updatedStreak.streakLength += 1
            
            if update(updatedStreak) {
                return updatedStreak
            }
            return nil
        } else {
            // No current streak, start a new one
            return startNewStreak(userId: userId)
        }
    }
    
    /// Get the user's longest streak
    /// - Parameter userId: The user ID to get the longest streak for
    /// - Returns: The longest streak history, or nil if no streaks exist or if there was an error
    func getLongestStreak(userId: Int) -> StreakHistory? {
        do {
            return try dbQueue.read { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .order(Column(StreakHistory.CodingKeys.streakLength.stringValue).desc)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching longest streak for user: \(error)")
            return nil
        }
    }
    
    /// Get all streaks longer than a specified length
    /// - Parameters:
    ///   - userId: The user ID to get streaks for
    ///   - length: The minimum length to filter by
    /// - Returns: Array of streaks longer than the specified length, empty array if none or if there was an error
    func getStreaksLongerThan(userId: Int, length: Int) -> [StreakHistory] {
        do {
            return try dbQueue.read { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(StreakHistory.CodingKeys.streakLength.stringValue) > length)
                    .order(Column(StreakHistory.CodingKeys.streakLength.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching streaks longer than \(length): \(error)")
            return []
        }
    }
    
    /// Get streaks within a specific date range
    /// - Parameters:
    ///   - userId: The user ID to get streaks for
    ///   - startDate: The beginning of the date range
    ///   - endDate: The end of the date range
    /// - Returns: Array of streaks within the date range, empty array if none or if there was an error
    func getStreaksInDateRange(userId: Int, startDate: Date, endDate: Date) -> [StreakHistory] {
        do {
            return try dbQueue.read { db in
                try StreakHistory
                    .filter(Column(StreakHistory.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(StreakHistory.CodingKeys.startDate.stringValue) >= startDate)
                    .filter(sql: """
                        (\(StreakHistory.CodingKeys.endDate.stringValue) IS NULL OR 
                         \(StreakHistory.CodingKeys.endDate.stringValue) <= ?)
                    """, arguments: [endDate])
                    .order(Column(StreakHistory.CodingKeys.startDate.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching streaks in date range: \(error)")
            return []
        }
    }
    
    /// Check if a user has an active streak
    /// - Parameter userId: The user ID to check
    /// - Returns: True if the user has an active streak, false otherwise
    func hasActiveStreak(userId: Int) -> Bool {
        return getCurrentStreak(userId: userId) != nil
    }
}
