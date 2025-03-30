//
//  SwearWordRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing SwearWord entities in the database
class SwearWordRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new swear word in the dictionary
    /// - Parameter word: The swear word to create
    /// - Returns: The created word with ID assigned, or nil if creation failed
    func create(_ word: SwearWord) -> SwearWord? {
        do {
            var newWord = word
            try dbQueue.write { db in
                try newWord.insert(db)
            }
            return newWord
        } catch {
            print("Error creating swear word: \(error)")
            return nil
        }
    }
    
    /// Retrieve a swear word by ID
    /// - Parameter id: The ID of the word to retrieve
    /// - Returns: The word if found, nil otherwise
    func getById(_ id: Int) -> SwearWord? {
        do {
            return try dbQueue.read { db in
                try SwearWord.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching swear word by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve a swear word by its text
    /// - Parameter word: The text of the word to retrieve
    /// - Returns: The word if found, nil otherwise
    func getByWord(_ word: String) -> SwearWord? {
        do {
            return try dbQueue.read { db in
                try SwearWord
                    .filter(Column(SwearWord.CodingKeys.word.stringValue) == word)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching swear word by text: \(error)")
            return nil
        }
    }
    
    /// Retrieve all swear words
    /// - Parameter includeCustom: Whether to include custom words (default: true)
    /// - Returns: Array of swear words, empty array if none or if there was an error
    func getAll(includeCustom: Bool = true) -> [SwearWord] {
        do {
            return try dbQueue.read { db in
                if includeCustom {
                    return try SwearWord.fetchAll(db)
                } else {
                    return try SwearWord
                        .filter(Column(SwearWord.CodingKeys.isCustom.stringValue) == false)
                        .fetchAll(db)
                }
            }
        } catch {
            print("Error fetching all swear words: \(error)")
            return []
        }
    }
    
    /// Update an existing swear word
    /// - Parameter word: The word to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ word: SwearWord) -> Bool {
        guard word.id != nil else {
            print("Error updating swear word: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try word.update(db)
            }
            return true
        } catch {
            print("Error updating swear word: \(error)")
            return false
        }
    }
    
    /// Delete a swear word by ID
    /// - Parameter id: The ID of the word to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try SwearWord.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting swear word: \(error)")
            return false
        }
    }
    
    // MARK: - Additional Methods
    
    /// Retrieve words by severity level
    /// - Parameter severity: The severity level to filter by
    /// - Returns: Array of words matching the severity, empty array if none or if there was an error
    func getBySeverity(_ severity: SwearWord.Severity) -> [SwearWord] {
        do {
            return try dbQueue.read { db in
                try SwearWord
                    .filter(Column(SwearWord.CodingKeys.severity.stringValue) == severity.rawValue)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching words by severity: \(error)")
            return []
        }
    }
    
    /// Search for swear words containing the given text
    /// - Parameter searchText: The text to search for
    /// - Returns: Array of matching words, empty array if none or if there was an error
    func search(text searchText: String) -> [SwearWord] {
        let searchPattern = "%\(searchText)%"
        
        do {
            return try dbQueue.read { db in
                try SwearWord
                    .filter(Column(SwearWord.CodingKeys.word.stringValue).like(searchPattern))
                    .fetchAll(db)
            }
        } catch {
            print("Error searching swear words: \(error)")
            return []
        }
    }
    
    /// Get the count of swear words in the dictionary
    /// - Parameter includeCustom: Whether to include custom words in the count
    /// - Returns: The number of words, or 0 if there was an error
    func getCount(includeCustom: Bool = true) -> Int {
        do {
            return try dbQueue.read { db in
                if includeCustom {
                    return try SwearWord.fetchCount(db)
                } else {
                    return try SwearWord
                        .filter(Column(SwearWord.CodingKeys.isCustom.stringValue) == false)
                        .fetchCount(db)
                }
            }
        } catch {
            print("Error getting swear word count: \(error)")
            return 0
        }
    }
    
    /// Add a set of default swear words to the dictionary
    /// - Returns: The number of words added, or 0 if there was an error
    func seedDefaultWords() -> Int {
        let defaultWords = [
            SwearWord(word: "damn", severity: .mild),
            SwearWord(word: "hell", severity: .mild),
            SwearWord(word: "crap", severity: .mild),
            SwearWord(word: "ass", severity: .moderate),
            SwearWord(word: "bastard", severity: .moderate),
            SwearWord(word: "bitch", severity: .moderate),
            SwearWord(word: "shit", severity: .severe),
            SwearWord(word: "f**k", severity: .severe)
        ]
        
        var addedCount = 0
        
        for word in defaultWords {
            // Skip if word already exists
            if getByWord(word.word) != nil {
                continue
            }
            
            if create(word) != nil {
                addedCount += 1
            }
        }
        
        return addedCount
    }
}
