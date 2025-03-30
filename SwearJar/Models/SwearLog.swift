//
//  SwearLog.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a logged swear word instance
struct SwearLog: Identifiable, Codable {
    /// Database ID for the log entry
    var id: Int?
    
    /// Reference to the user who logged the swear
    var userId: Int
    
    /// Reference to the swear word used
    var wordId: Int
    
    /// When the swear was logged
    var timestamp: Date
    
    /// Emotional state when the swear occurred
    var mood: Mood?
    
    /// Whether the user felt it was worth swearing
    var worthIt: Bool?
    
    /// Optional context or situation information
    var context: String?
    
    /// Fine amount for this specific instance
    var fineAmount: Double
    
    /// Optional location where the swear occurred
    var location: String?
    
    /// Emotional states tracked with swearing
    enum Mood: String, Codable, CaseIterable {
        case angry
        case frustrated
        case surprised
        case amused
        case stressed
        case other
        
        /// Returns a display-friendly name for the mood
        var displayName: String {
            switch self {
            case .angry:
                return "Angry"
            case .frustrated:
                return "Frustrated"
            case .surprised:
                return "Surprised"
            case .amused:
                return "Amused"
            case .stressed:
                return "Stressed"
            case .other:
                return "Other"
            }
        }
        
        /// Returns the corresponding emoji for the mood
        var emoji: String {
            switch self {
            case .angry:
                return "😡"
            case .frustrated:
                return "😤"
            case .surprised:
                return "😯"
            case .amused:
                return "😏"
            case .stressed:
                return "😰"
            case .other:
                return "🤔"
            }
        }
    }
    
    /// Creates a new SwearLog with default values
    init(id: Int? = nil,
         userId: Int,
         wordId: Int,
         timestamp: Date = Date(),
         mood: Mood? = nil,
         worthIt: Bool? = nil,
         context: String? = nil,
         fineAmount: Double,
         location: String? = nil) {
        
        self.id = id
        self.userId = userId
        self.wordId = wordId
        self.timestamp = timestamp
        self.mood = mood
        self.worthIt = worthIt
        self.context = context
        self.fineAmount = fineAmount
        self.location = location
    }
    
    /// Database table name for the SwearLog model
    static let tableName = "swear_logs"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "log_id"
        case userId = "user_id"
        case wordId = "word_id"
        case timestamp
        case mood
        case worthIt = "worth_it"
        case context
        case fineAmount = "fine_amount"
        case location
    }
}

// MARK: - GRDB Extensions
extension SwearLog: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        userId = row[CodingKeys.userId.stringValue] as Int
        wordId = row[CodingKeys.wordId.stringValue] as Int
        timestamp = row[CodingKeys.timestamp.stringValue] as Date
        
        if let moodString = row[CodingKeys.mood.stringValue] as String? {
            mood = Mood(rawValue: moodString)
        } else {
            mood = nil
        }
        
        worthIt = row[CodingKeys.worthIt.stringValue] as Bool?
        context = row[CodingKeys.context.stringValue] as String?
        fineAmount = row[CodingKeys.fineAmount.stringValue] as Double
        location = row[CodingKeys.location.stringValue] as String?
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.userId.stringValue] = userId
        container[CodingKeys.wordId.stringValue] = wordId
        container[CodingKeys.timestamp.stringValue] = timestamp
        container[CodingKeys.mood.stringValue] = mood?.rawValue
        container[CodingKeys.worthIt.stringValue] = worthIt
        container[CodingKeys.context.stringValue] = context
        container[CodingKeys.fineAmount.stringValue] = fineAmount
        container[CodingKeys.location.stringValue] = location
        
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
