//
//  StreakHistory.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a streak history record for tracking clean day streaks
struct StreakHistory: Identifiable, Codable {
    /// Database ID for the streak record
    var id: Int?
    
    /// Reference to the user this streak belongs to
    var userId: Int
    
    /// Length of the streak in days
    var streakLength: Int
    
    /// Date when the streak started
    var startDate: Date
    
    /// Date when the streak ended (nil if still active)
    var endDate: Date?
    
    /// Whether this is the user's current active streak
    var isCurrent: Bool
    
    /// Creates a new StreakHistory instance with default values
    init(id: Int? = nil,
         userId: Int,
         streakLength: Int,
         startDate: Date,
         endDate: Date? = nil,
         isCurrent: Bool = true) {
        
        self.id = id
        self.userId = userId
        self.streakLength = streakLength
        self.startDate = startDate
        self.endDate = endDate
        self.isCurrent = isCurrent
    }
    
    /// Database table name for the StreakHistory model
    static let tableName = "streak_history"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "streak_id"
        case userId = "user_id"
        case streakLength = "streak_length"
        case startDate = "start_date"
        case endDate = "end_date"
        case isCurrent = "is_current"
    }
}

// MARK: - GRDB Extensions
extension StreakHistory: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        userId = row[CodingKeys.userId.stringValue] as Int
        streakLength = row[CodingKeys.streakLength.stringValue] as Int
        startDate = row[CodingKeys.startDate.stringValue] as Date
        endDate = row[CodingKeys.endDate.stringValue] as Date?
        isCurrent = row[CodingKeys.isCurrent.stringValue] as Bool
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.userId.stringValue] = userId
        container[CodingKeys.streakLength.stringValue] = streakLength
        container[CodingKeys.startDate.stringValue] = startDate
        container[CodingKeys.endDate.stringValue] = endDate
        container[CodingKeys.isCurrent.stringValue] = isCurrent
        
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
