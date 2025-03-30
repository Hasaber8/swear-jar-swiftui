//
//  UserWordRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing UserWord entities in the database
class UserWordRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new user-word association
    /// - Parameter userWord: The user-word to create
    /// - Returns: The created user-word with ID assigned, or nil if creation failed
    func create(_ userWord: UserWord) -> UserWord? {
        do {
            var newUserWord = userWord
            try dbQueue.write { db in
                try newUserWord.insert(db)
            }
            return newUserWord
        } catch {
            print("Error creating user word: \(error)")
            return nil
        }
    }
    
    /// Retrieve a user-word by ID
    /// - Parameter id: The ID of the user-word to retrieve
    /// - Returns: The user-word if found, nil otherwise
    func getById(_ id: Int) -> UserWord? {
        do {
            return try dbQueue.read { db in
                try UserWord.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching user word by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve a user-word by user ID and word ID
    /// - Parameters:
    ///   - userId: The user ID to filter by
    ///   - wordId: The word ID to filter by
    /// - Returns: The user-word if found, nil otherwise
    func getByUserAndWord(userId: Int, wordId: Int) -> UserWord? {
        do {
            return try dbQueue.read { db in
                try UserWord
                    .filter(Column(UserWord.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(UserWord.CodingKeys.wordId.stringValue) == wordId)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching user word by user and word IDs: \(error)")
            return nil
        }
    }
    
    /// Retrieve all user-words for a specific user
    /// - Parameter userId: The user ID to filter by
    /// - Returns: Array of user-words for the specified user, empty array if none or if there was an error
    func getAllForUser(userId: Int) -> [UserWord] {
        do {
            return try dbQueue.read { db in
                try UserWord
                    .filter(Column(UserWord.CodingKeys.userId.stringValue) == userId)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching all user words for user: \(error)")
            return []
        }
    }
    
    /// Update an existing user-word
    /// - Parameter userWord: The user-word to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ userWord: UserWord) -> Bool {
        guard userWord.id != nil else {
            print("Error updating user word: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try userWord.update(db)
            }
            return true
        } catch {
            print("Error updating user word: \(error)")
            return false
        }
    }
    
    /// Delete a user-word by ID
    /// - Parameter id: The ID of the user-word to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try UserWord.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting user word: \(error)")
            return false
        }
    }
    
    /// Delete a user-word by user ID and word ID
    /// - Parameters:
    ///   - userId: The user ID of the user-word to delete
    ///   - wordId: The word ID of the user-word to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func deleteByUserAndWord(userId: Int, wordId: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try UserWord
                    .filter(Column(UserWord.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(UserWord.CodingKeys.wordId.stringValue) == wordId)
                    .deleteAll(db)
            }
            return true
        } catch {
            print("Error deleting user word by user and word IDs: \(error)")
            return false
        }
    }
    
    /// Delete all user-words for a specific user
    /// - Parameter userId: The user ID to delete user-words for
    /// - Returns: The number of user-words deleted, or 0 if there was an error
    func deleteAllForUser(userId: Int) -> Int {
        do {
            return try dbQueue.write { db in
                try UserWord
                    .filter(Column(UserWord.CodingKeys.userId.stringValue) == userId)
                    .deleteAll(db)
            }
        } catch {
            print("Error deleting all user words for user: \(error)")
            return 0
        }
    }
    
    // MARK: - Additional Methods
    
    /// Get or create a user-word association
    /// - Parameters:
    ///   - userId: The user ID for the association
    ///   - wordId: The word ID for the association
    /// - Returns: The user-word association, or nil if there was an error
    func getOrCreate(userId: Int, wordId: Int) -> UserWord? {
        // Try to get existing user-word
        if let userWord = getByUserAndWord(userId: userId, wordId: wordId) {
            return userWord
        }
        
        // Get the default fine from the swear word
        var defaultFine: Double = 0.25 // Fallback default
        do {
            let swearWordFine = try dbQueue.read { db in
                try SwearWord
                    .select(Column(SwearWord.CodingKeys.defaultFine.stringValue))
                    .filter(Column(SwearWord.CodingKeys.id.stringValue) == wordId)
                    .asRequest(of: Double.self)
                    .fetchOne(db)
            }
            
            if let fine = swearWordFine {
                defaultFine = fine
            }
        } catch {
            print("Error getting default fine for word: \(error)")
        }
        
        // Create with default settings
        let newUserWord = UserWord(
            userId: userId,
            wordId: wordId,
            customFine: defaultFine,
            isActive: true
        )
        
        return create(newUserWord)
    }
    
    /// Update the custom fine for a user-word
    /// - Parameters:
    ///   - userId: The user ID for the association
    ///   - wordId: The word ID for the association
    ///   - fine: The new custom fine amount
    /// - Returns: True if the update was successful, false otherwise
    func updateCustomFine(userId: Int, wordId: Int, fine: Double) -> Bool {
        // First get or create the user-word
        guard let userWord = getOrCreate(userId: userId, wordId: wordId) else {
            return false
        }
        
        // Update the fine
        var updatedUserWord = userWord
        updatedUserWord.customFine = fine
        
        return update(updatedUserWord)
    }
    
    /// Update the active status for a user-word
    /// - Parameters:
    ///   - userId: The user ID for the association
    ///   - wordId: The word ID for the association
    ///   - active: The new active status
    /// - Returns: True if the update was successful, false otherwise
    func updateActiveStatus(userId: Int, wordId: Int, active: Bool) -> Bool {
        // First get or create the user-word
        guard let userWord = getOrCreate(userId: userId, wordId: wordId) else {
            return false
        }
        
        // Update the active status
        var updatedUserWord = userWord
        updatedUserWord.isActive = active
        
        return update(updatedUserWord)
    }
    
    /// Get all active words for a user with their custom settings
    /// - Parameter userId: The user ID to get active words for
    /// - Returns: Array of user-words that are active, empty array if none or if there was an error
    func getActiveWords(userId: Int) -> [UserWord] {
        do {
            return try dbQueue.read { db in
                try UserWord
                    .filter(Column(UserWord.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(UserWord.CodingKeys.isActive.stringValue) == true)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching active words for user: \(error)")
            return []
        }
    }
    
    /// Get the custom fine for a specific user-word
    /// - Parameters:
    ///   - userId: The user ID for the association
    ///   - wordId: The word ID for the association
    /// - Returns: The custom fine amount, or the word's default fine if no custom setting exists
    func getFineAmount(userId: Int, wordId: Int) -> Double {
        // Try to get the user's custom setting
        if let userWord = getByUserAndWord(userId: userId, wordId: wordId),
           let customFine = userWord.customFine {
            return customFine
        }
        
        // Fall back to the word's default fine
        do {
            let swearWordFine = try dbQueue.read { db in
                try SwearWord
                    .select(Column(SwearWord.CodingKeys.defaultFine.stringValue))
                    .filter(Column(SwearWord.CodingKeys.id.stringValue) == wordId)
                    .asRequest(of: Double.self)
                    .fetchOne(db)
            }
            
            return swearWordFine ?? 0.25 // Default if nothing else works
        } catch {
            print("Error getting default fine for word: \(error)")
            return 0.25 // Fallback default
        }
    }
}
