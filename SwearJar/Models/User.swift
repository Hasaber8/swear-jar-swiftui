//
//  User.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a user in the SwearJar app
struct User: Identifiable, Codable {
    /// Database ID for the user
    var id: Int?
    
    /// Username for login (required)
    var username: String
    
    /// Display name shown in the UI (optional)
    var displayName: String?
    
    /// Path to the user's avatar image
    var avatarPath: String?
    
    /// Timestamp when the user was created
    var createdAt: Date
    
    /// Timestamp of the user's last activity
    var lastActive: Date
    
    /// Current streak of days without swearing
    var streakDays: Int
    
    /// Total number of swears logged by this user
    var totalSwears: Int
    
    /// Total fine amount accumulated (based on swear severity and settings)
    var totalFine: Double
    
    /// Creates a new user with default values
    init(id: Int? = nil,
         username: String,
         displayName: String? = nil,
         avatarPath: String? = nil,
         createdAt: Date = Date(),
         lastActive: Date = Date(),
         streakDays: Int = 0,
         totalSwears: Int = 0,
         totalFine: Double = 0.0) {
        
        self.id = id
        self.username = username
        self.displayName = displayName
        self.avatarPath = avatarPath
        self.createdAt = createdAt
        self.lastActive = lastActive
        self.streakDays = streakDays
        self.totalSwears = totalSwears
        self.totalFine = totalFine
    }
    
    /// Database table name for the User model
    static let tableName = "users"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case username
        case displayName = "display_name"
        case avatarPath = "avatar_path"
        case createdAt = "created_at"
        case lastActive = "last_active"
        case streakDays = "streak_days"
        case totalSwears = "total_swears"
        case totalFine = "total_fine"
    }
}

// MARK: - GRDB Extensions
extension User: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        username = row[CodingKeys.username.stringValue] as String
        displayName = row[CodingKeys.displayName.stringValue] as String?
        avatarPath = row[CodingKeys.avatarPath.stringValue] as String?
        createdAt = row[CodingKeys.createdAt.stringValue] as Date
        lastActive = row[CodingKeys.lastActive.stringValue] as Date
        streakDays = row[CodingKeys.streakDays.stringValue] as Int
        totalSwears = row[CodingKeys.totalSwears.stringValue] as Int
        totalFine = row[CodingKeys.totalFine.stringValue] as Double
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.username.stringValue] = username
        container[CodingKeys.displayName.stringValue] = displayName
        container[CodingKeys.avatarPath.stringValue] = avatarPath
        container[CodingKeys.createdAt.stringValue] = createdAt
        container[CodingKeys.lastActive.stringValue] = lastActive
        container[CodingKeys.streakDays.stringValue] = streakDays
        container[CodingKeys.totalSwears.stringValue] = totalSwears
        container[CodingKeys.totalFine.stringValue] = totalFine
        
        // Only include id for updates, not inserts
        if let id = id {
            container[CodingKeys.id.stringValue] = id
        }
    }
    
    /// Update the id after a successful insertion
    mutating func didInsert(_ inserted: InsertionSuccess) {
        print("UserID is \(inserted.rowID)")
        id = Int(inserted.rowID)
    }
}
