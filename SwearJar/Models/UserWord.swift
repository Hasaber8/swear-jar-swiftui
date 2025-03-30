//
//  UserWord.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a user's custom settings for a swear word
struct UserWord: Identifiable, Codable {
    /// Database ID for the user-word relationship
    var id: Int?
    
    /// Reference to the user
    var userId: Int
    
    /// Reference to the swear word
    var wordId: Int
    
    /// User's custom fine amount (overrides the default)
    var customFine: Double?
    
    /// Whether this word is active for the user
    var isActive: Bool
    
    /// Creates a new UserWord with default values
    init(id: Int? = nil,
         userId: Int,
         wordId: Int,
         customFine: Double? = nil,
         isActive: Bool = true) {
        
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.customFine = customFine
        self.isActive = isActive
    }
    
    /// Database table name for the UserWord model
    static let tableName = "user_words"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "user_word_id"
        case userId = "user_id"
        case wordId = "word_id"
        case customFine = "custom_fine"
        case isActive = "is_active"
    }
}

// MARK: - GRDB Extensions
extension UserWord: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        userId = row[CodingKeys.userId.stringValue] as Int
        wordId = row[CodingKeys.wordId.stringValue] as Int
        customFine = row[CodingKeys.customFine.stringValue] as Double?
        isActive = row[CodingKeys.isActive.stringValue] as Bool
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.userId.stringValue] = userId
        container[CodingKeys.wordId.stringValue] = wordId
        container[CodingKeys.customFine.stringValue] = customFine
        container[CodingKeys.isActive.stringValue] = isActive
        
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
