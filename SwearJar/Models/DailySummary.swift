//
//  DailySummary.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a daily summary of swear activity for analytics
struct DailySummary: Identifiable, Codable {
    /// Database ID for the summary record
    var id: Int?
    
    /// Reference to the user this summary belongs to
    var userId: Int
    
    /// Date for this summary in YYYY-MM-DD format
    var date: String
    
    /// Total count of swears for this day
    var swearCount: Int
    
    /// Total fine amount accumulated for this day
    var totalFine: Double
    
    /// ID of the most commonly used word for this day
    var mostCommonWordId: Int?
    
    /// Most common mood for this day
    var mostCommonMood: String?
    
    /// Whether this was a clean day (no swears)
    var isCleanDay: Bool
    
    /// Creates a new DailySummary instance with default values
    init(id: Int? = nil,
         userId: Int,
         date: String,
         swearCount: Int = 0,
         totalFine: Double = 0.0,
         mostCommonWordId: Int? = nil,
         mostCommonMood: String? = nil,
         isCleanDay: Bool = true) {
        
        self.id = id
        self.userId = userId
        self.date = date
        self.swearCount = swearCount
        self.totalFine = totalFine
        self.mostCommonWordId = mostCommonWordId
        self.mostCommonMood = mostCommonMood
        self.isCleanDay = isCleanDay
    }
    
    /// Database table name for the DailySummary model
    static let tableName = "daily_summaries"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "summary_id"
        case userId = "user_id"
        case date
        case swearCount = "swear_count"
        case totalFine = "total_fine"
        case mostCommonWordId = "most_common_word_id"
        case mostCommonMood = "most_common_mood"
        case isCleanDay = "clean_day"
    }
    
    /// Formatter for converting between Date objects and YYYY-MM-DD string format
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Creates a date string in YYYY-MM-DD format from a Date object
    static func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    /// Creates a Date object from a YYYY-MM-DD formatted string
    static func parseDate(_ dateString: String) -> Date? {
        return dateFormatter.date(from: dateString)
    }
}

// MARK: - GRDB Extensions
extension DailySummary: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        userId = row[CodingKeys.userId.stringValue] as Int
        date = row[CodingKeys.date.stringValue] as String
        swearCount = row[CodingKeys.swearCount.stringValue] as Int
        totalFine = row[CodingKeys.totalFine.stringValue] as Double
        mostCommonWordId = row[CodingKeys.mostCommonWordId.stringValue] as Int?
        mostCommonMood = row[CodingKeys.mostCommonMood.stringValue] as String?
        isCleanDay = row[CodingKeys.isCleanDay.stringValue] as Bool
    }
    
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.userId.stringValue] = userId
        container[CodingKeys.date.stringValue] = date
        container[CodingKeys.swearCount.stringValue] = swearCount
        container[CodingKeys.totalFine.stringValue] = totalFine
        container[CodingKeys.mostCommonWordId.stringValue] = mostCommonWordId
        container[CodingKeys.mostCommonMood.stringValue] = mostCommonMood
        container[CodingKeys.isCleanDay.stringValue] = isCleanDay
        
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
