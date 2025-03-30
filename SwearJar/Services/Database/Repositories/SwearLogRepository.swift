//
//  SwearLogRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing SwearLog entities in the database
class SwearLogRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new swear log entry
    /// - Parameter log: The log entry to create
    /// - Returns: The created log with ID assigned, or nil if creation failed
    func create(_ log: SwearLog) -> SwearLog? {
        do {
            var newLog = log
            try dbQueue.write { db in
                try newLog.insert(db)
            }
            return newLog
        } catch {
            print("Error creating swear log: \(error)")
            return nil
        }
    }
    
    /// Retrieve a log entry by ID
    /// - Parameter id: The ID of the log to retrieve
    /// - Returns: The log if found, nil otherwise
    func getById(_ id: Int) -> SwearLog? {
        do {
            return try dbQueue.read { db in
                try SwearLog.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching swear log by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve all log entries for a user
    /// - Parameter userId: The user ID to get logs for
    /// - Returns: Array of logs, empty array if none or if there was an error
    func getByUserId(_ userId: Int) -> [SwearLog] {
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .order(Column(SwearLog.CodingKeys.timestamp.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching logs by user ID: \(error)")
            return []
        }
    }
    
    /// Update an existing log entry
    /// - Parameter log: The log to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ log: SwearLog) -> Bool {
        guard log.id != nil else {
            print("Error updating swear log: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try log.update(db)
            }
            return true
        } catch {
            print("Error updating swear log: \(error)")
            return false
        }
    }
    
    /// Delete a log entry by ID
    /// - Parameter id: The ID of the log to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try SwearLog.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting swear log: \(error)")
            return false
        }
    }
    
    /// Delete all logs for a specific user
    /// - Parameter userId: The user ID to delete logs for
    /// - Returns: The number of logs deleted, or 0 if there was an error
    func deleteAllForUser(userId: Int) -> Int {
        do {
            return try dbQueue.write { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .deleteAll(db)
            }
        } catch {
            print("Error deleting user logs: \(error)")
            return 0
        }
    }
    
    // MARK: - Query Methods
    
    /// Get recent logs for a user, with optional limit
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - limit: Maximum number of logs to retrieve
    /// - Returns: Array of recent logs, empty array if none or if there was an error
    func getRecentLogs(userId: Int, limit: Int = 10) -> [SwearLog] {
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .order(Column(SwearLog.CodingKeys.timestamp.stringValue).desc)
                    .limit(limit)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching recent logs: \(error)")
            return []
        }
    }
    
    /// Get logs for a specific date range
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - startDate: Beginning of the date range
    ///   - endDate: End of the date range
    /// - Returns: Array of logs within the date range, empty array if none or if there was an error
    func getLogsInDateRange(userId: Int, startDate: Date, endDate: Date) -> [SwearLog] {
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) >= startDate)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) <= endDate)
                    .order(Column(SwearLog.CodingKeys.timestamp.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching logs in date range: \(error)")
            return []
        }
    }
    
    /// Get logs for a specific day
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - date: The date to get logs for
    /// - Returns: Array of logs for the specified day, empty array if none or if there was an error
    func getLogsForDay(userId: Int, date: Date) -> [SwearLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return getLogsInDateRange(userId: userId, startDate: startOfDay, endDate: endOfDay)
    }
    
    /// Get logs for today
    /// - Parameter userId: The user ID to get logs for
    /// - Returns: Array of logs for today, empty array if none or if there was an error
    func getLogsForToday(userId: Int) -> [SwearLog] {
        return getLogsForDay(userId: userId, date: Date())
    }
    
    /// Get logs by mood
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - mood: The mood to filter by
    /// - Returns: Array of logs with the specified mood, empty array if none or if there was an error
    func getLogsByMood(userId: Int, mood: SwearLog.Mood) -> [SwearLog] {
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.mood.stringValue) == mood.rawValue)
                    .order(Column(SwearLog.CodingKeys.timestamp.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching logs by mood: \(error)")
            return []
        }
    }
    
    /// Get logs by swear word
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - wordId: The ID of the swear word to filter by
    /// - Returns: Array of logs with the specified word, empty array if none or if there was an error
    func getLogsByWord(userId: Int, wordId: Int) -> [SwearLog] {
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.wordId.stringValue) == wordId)
                    .order(Column(SwearLog.CodingKeys.timestamp.stringValue).desc)
                    .fetchAll(db)
            }
        } catch {
            print("Error fetching logs by word: \(error)")
            return []
        }
    }
    
    /// Get count of logs for a specific day
    /// - Parameters:
    ///   - userId: The user ID to count logs for
    ///   - date: The date to count logs for
    /// - Returns: The number of logs, or 0 if there was an error
    func getCountForDay(userId: Int, date: Date) -> Int {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        do {
            return try dbQueue.read { db in
                try SwearLog
                    .filter(Column(SwearLog.CodingKeys.userId.stringValue) == userId)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) >= startOfDay)
                    .filter(Column(SwearLog.CodingKeys.timestamp.stringValue) < endOfDay)
                    .fetchCount(db)
            }
        } catch {
            print("Error counting logs for day: \(error)")
            return 0
        }
    }
    
    /// Check if user has any logs for a specific day
    /// - Parameters:
    ///   - userId: The user ID to check logs for
    ///   - date: The date to check logs for
    /// - Returns: True if the user has logs for the specified day, false otherwise
    func hasLogsForDay(userId: Int, date: Date) -> Bool {
        return getCountForDay(userId: userId, date: date) > 0
    }
    
    /// Calculate total fine amount for a specific day
    /// - Parameters:
    ///   - userId: The user ID to calculate fines for
    ///   - date: The date to calculate fines for
    /// - Returns: The total fine amount, or 0 if there was an error
    func getTotalFineForDay(userId: Int, date: Date) -> Double {
        let logs = getLogsForDay(userId: userId, date: date)
        return logs.reduce(0) { $0 + $1.fineAmount }
    }
}
