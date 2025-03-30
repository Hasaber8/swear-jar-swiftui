//
//  DailySummaryRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing DailySummary entities in the database
class DailySummaryRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new daily summary
    /// - Parameter summary: The daily summary to create
    /// - Returns: The created summary with ID assigned, or nil if creation failed
    func create(_ summary: DailySummary) -> DailySummary? {
        do {
            var newSummary = summary
            try dbQueue.write { db in
                try newSummary.insert(db)
            }
            return newSummary
        } catch {
            print("Error creating daily summary: \(error)")
            return nil
        }
    }
    
    /// Retrieve a daily summary by ID
    /// - Parameter id: The ID of the summary to retrieve
    /// - Returns: The summary if found, nil otherwise
    func getById(_ id: Int) -> DailySummary? {
        do {
            return try dbQueue.read { db in
                try DailySummary.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching daily summary by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve a daily summary by user ID and date
    /// - Parameters:
    ///   - userId: The user ID to filter by
    ///   - date: The date to filter by (format: "YYYY-MM-DD")
    /// - Returns: The summary if found, nil otherwise
    func getByUserAndDate(userId: Int, date: String) -> DailySummary? {
        do {
            return try dbQueue.read { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(DailySummary.CodingKeys.date.stringValue) == date)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching daily summary by user and date: \(error)")
            return nil
        }
    }
    
    /// Retrieve all daily summaries for a user
    /// - Parameter userId: The user ID to filter by
    /// - Returns: Array of daily summaries, empty array if none or if there was an error
    func getAllForUser(userId: Int) -> [DailySummary] {
        do {
            return try dbQueue.read { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .order(Column(DailySummary.CodingKeys.date.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching daily summaries for user: \(error)")
            return []
        }
    }
    
    /// Update an existing daily summary
    /// - Parameter summary: The summary to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ summary: DailySummary) -> Bool {
        guard summary.id != nil else {
            print("Error updating daily summary: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try summary.update(db)
            }
            return true
        } catch {
            print("Error updating daily summary: \(error)")
            return false
        }
    }
    
    /// Delete a daily summary by ID
    /// - Parameter id: The ID of the summary to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try DailySummary.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting daily summary: \(error)")
            return false
        }
    }
    
    /// Delete all daily summaries for a user
    /// - Parameter userId: The user ID to delete summaries for
    /// - Returns: The number of summaries deleted, or 0 if there was an error
    func deleteAllForUser(userId: Int) -> Int {
        do {
            return try dbQueue.write { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .deleteAll(db)
            }
        } catch {
            print("Error deleting daily summaries for user: \(error)")
            return 0
        }
    }
    
    // MARK: - Summary Generation
    
    /// Generate or update a daily summary for a specific day
    /// - Parameters:
    ///   - userId: The user ID to generate a summary for
    ///   - date: The date to generate a summary for
    /// - Returns: The generated or updated summary, or nil if there was an error
    func generateSummary(userId: Int, date: Date) -> DailySummary? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        // Check if a summary already exists
        let existingSummary = getByUserAndDate(userId: userId, date: dateString)
        
        // Generate summary data from logs
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            // Get count and total fine for the day
            let (count, totalFine) = try dbQueue.read { db -> (Int, Double) in
                let count = try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) >= startOfDay)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) < endOfDay)
                    .fetchCount(db)
                
                let totalFine = try SwearLog
                    .select(sum(Column(SwearLog.CodingKeys.fineAmount.stringValue)))
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) >= startOfDay)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) < endOfDay)
                    .asRequest(of: Double.self)
                    .fetchOne(db) ?? 0.0
                
                return (count, totalFine)
            }
            
            // Get most common word
            let commonWordId = try dbQueue.read { db -> Int? in
                // Use a raw SQL query for more complex aggregation
                let sql = """
                SELECT word_id, COUNT(*) as word_count
                FROM swear_logs
                WHERE user_id = ? 
                AND timestamp >= ?
                AND timestamp < ?
                GROUP BY word_id
                ORDER BY word_count DESC
                LIMIT 1
                """
                
                // Create StatementArguments with all values at once
                let arguments: StatementArguments = [userId, startOfDay, endOfDay]
                let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                return row?["word_id"]
            }
            
            // Get most common mood
            let commonMood = try dbQueue.read { db -> String? in
                let sql = """
                SELECT mood, COUNT(*) as mood_count
                FROM swear_logs
                WHERE user_id = ? 
                AND timestamp >= ?
                AND timestamp < ?
                AND mood IS NOT NULL
                GROUP BY mood
                ORDER BY mood_count DESC
                LIMIT 1
                """
                
                // Create StatementArguments with all values at once
                let arguments: StatementArguments = [userId, startOfDay, endOfDay]
                let row = try Row.fetchOne(db, sql: sql, arguments: arguments)
                return row?["mood"] as? String
            }
            
            // Determine clean day status
            let isCleanDay = count == 0
            
            // Create or update summary
            if let summary = existingSummary {
                var updatedSummary = summary
                updatedSummary.swearCount = count
                updatedSummary.totalFine = totalFine
                updatedSummary.mostCommonWordId = commonWordId
                updatedSummary.mostCommonMood = commonMood
                updatedSummary.isCleanDay = isCleanDay
                
                if update(updatedSummary) {
                    return updatedSummary
                }
                return nil
            } else {
                // Create a new summary
                let newSummary = DailySummary(
                    userId: userId,
                    date: dateString,
                    swearCount: count,
                    totalFine: totalFine,
                    mostCommonWordId: commonWordId,
                    mostCommonMood: commonMood,
                    isCleanDay: isCleanDay
                )
                
                return create(newSummary)
            }
        } catch {
            print("Error generating daily summary: \(error)")
            return nil
        }
    }
    
    // MARK: - Query Methods
    
    /// Get summaries for a date range
    /// - Parameters:
    ///   - userId: The user ID to get summaries for
    ///   - startDate: The beginning of the date range
    ///   - endDate: The end of the date range
    /// - Returns: Array of summaries within the date range, empty array if none or if there was an error
    func getSummariesInDateRange(userId: Int, startDate: Date, endDate: Date) -> [DailySummary] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        do {
            return try dbQueue.read { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(DailySummary.CodingKeys.date.stringValue) >= startDateString)
                    .filter(Column(DailySummary.CodingKeys.date.stringValue) <= endDateString)
                    .order(Column(DailySummary.CodingKeys.date.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching summaries in date range: \(error)")
            return []
        }
    }
    
    /// Get all clean days for a user
    /// - Parameter userId: The user ID to get clean days for
    /// - Returns: Array of summaries for clean days, empty array if none or if there was an error
    func getCleanDays(userId: Int) -> [DailySummary] {
        do {
            return try dbQueue.read { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(DailySummary.CodingKeys.isCleanDay.stringValue) == true)
                    .order(Column(DailySummary.CodingKeys.date.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching clean days: \(error)")
            return []
        }
    }
    
    /// Get the count of clean days for a user
    /// - Parameter userId: The user ID to count clean days for
    /// - Returns: The number of clean days, or 0 if there was an error
    func getCleanDayCount(userId: Int) -> Int {
        do {
            return try dbQueue.read { db in
                try DailySummary
                    .filter(Column(DailySummary.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(DailySummary.CodingKeys.isCleanDay.stringValue) == true)
                    .fetchCount(db)
            }
        } catch {
            print("Error counting clean days: \(error)")
            return 0
        }
    }
    
    /// Get the most common swear word for a user
    /// - Parameters:
    ///   - userId: The user ID to analyze
    ///   - timeFrame: Optional number of days to consider (nil = all time)
    /// - Returns: The ID of the most common word, or nil if there's no data or if there was an error
    func getMostCommonWord(userId: Int, timeFrame: Int? = nil) -> Int? {
        do {
            return try dbQueue.read { db -> Int? in
                var query = """
                SELECT most_common_word_id, COUNT(*) as frequency
                FROM daily_summaries
                WHERE user_id = ?
                AND most_common_word_id IS NOT NULL
                """
                
                // Start with base arguments
                var arguments: StatementArguments = [userId]
                
                if let days = timeFrame {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
                    let cutoffDateString = dateFormatter.string(from: cutoffDate)
                    
                    query += " AND date >= ?"
                    // Create a new StatementArguments with both values
                    arguments = [userId, cutoffDateString]
                }
                
                query += """
                GROUP BY most_common_word_id
                ORDER BY frequency DESC
                LIMIT 1
                """
                
                let row = try Row.fetchOne(db, sql: query, arguments: arguments)
                return row?["most_common_word_id"]
            }
        } catch {
            print("Error getting most common word: \(error)")
            return nil
        }
    }

    /// Get total fine amount for a user
    /// - Parameters:
    ///   - userId: The user ID to calculate fines for
    ///   - timeFrame: Optional number of days to consider (nil = all time)
    /// - Returns: The total fine amount, or 0 if there's no data or if there was an error
    func getTotalFine(userId: Int, timeFrame: Int? = nil) -> Double {
        do {
            return try dbQueue.read { db -> Double in
                var query = """
                SELECT SUM(total_fine) as total
                FROM daily_summaries
                WHERE user_id = ?
                """
                
                // Start with base arguments
                var arguments: StatementArguments = [userId]
                
                if let days = timeFrame {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
                    let cutoffDateString = dateFormatter.string(from: cutoffDate)
                    
                    query += " AND date >= ?"
                    // Create a new StatementArguments with both values
                    arguments = [userId, cutoffDateString]
                }
                
                let row = try Row.fetchOne(db, sql: query, arguments: arguments)
                return row?["total"] as? Double ?? 0.0
            }
        } catch {
            print("Error calculating total fine: \(error)")
            return 0.0
        }
    }
    
    
    /// Generate a summary for today if it doesn't exist
    /// - Parameter userId: The user ID to generate a summary for
    /// - Returns: The generated or existing summary, or nil if there was an error
    func ensureTodaySummary(userId: Int) -> DailySummary? {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        if let existingSummary = getByUserAndDate(userId: userId, date: todayString) {
            return existingSummary
        } else {
            return generateSummary(userId: userId, date: today)
        }
    }
}
