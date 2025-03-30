//
//  SwearLogService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing swear log-related operations
class SwearLogService {
    
    // MARK: - Properties
    
    private let swearLogRepository: SwearLogRepository
    
    // MARK: - Initialization
    
    init(swearLogRepository: SwearLogRepository = SwearLogRepository()) {
        self.swearLogRepository = swearLogRepository
    }
    
    // MARK: - Logging Management
    
    /// Log a new swear event
    /// - Parameters:
    ///   - userId: The ID of the user who swore
    ///   - wordId: The ID of the swear word used
    ///   - mood: The mood during the event
    ///   - context: The context or situation of the event
    ///   - fineAmount: The fine amount for the swear event
    /// - Returns: The created swear log, or nil if creation failed
    func logSwearEvent(userId: Int, wordId: Int, mood: SwearLog.Mood?, context: String?, fineAmount: Double) -> SwearLog? {
        let newLog = SwearLog(
            userId: userId,
            wordId: wordId,
            timestamp: Date(),
            mood: mood,
            worthIt: false, // Default value, can be updated later
            context: context,
            fineAmount: fineAmount,
            location: nil // Default value, can be updated later
        )
        
        return swearLogRepository.create(newLog)
    }
    
    // MARK: - Analytics
    
    /// Get recent swear logs for a user
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - limit: Maximum number of logs to retrieve
    /// - Returns: Array of recent swear logs
    func getRecentLogs(userId: Int, limit: Int = 10) -> [SwearLog] {
        return swearLogRepository.getRecentLogs(userId: userId, limit: limit)
    }
    
    /// Get swear logs for a specific day
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - date: The date to get logs for
    /// - Returns: Array of swear logs for the specified day
    func getLogsForDay(userId: Int, date: Date) -> [SwearLog] {
        return swearLogRepository.getLogsForDay(userId: userId, date: date)
    }
    
    /// Get the total fine amount for a specific day
    /// - Parameters:
    ///   - userId: The user ID to calculate fines for
    ///   - date: The date to calculate fines for
    /// - Returns: The total fine amount for the specified day
    func getTotalFineForDay(userId: Int, date: Date) -> Double {
        return swearLogRepository.getTotalFineForDay(userId: userId, date: date)
    }
    
    /// Update an existing swear log entry
    /// - Parameter log: The log to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func updateLog(_ log: SwearLog) -> Bool {
        return swearLogRepository.update(log)
    }
    
    /// Delete a log entry by ID
    /// - Parameter id: The ID of the log to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func deleteLog(id: Int) -> Bool {
        return swearLogRepository.delete(id: id)
    }
    
    /// Delete all logs for a specific user
    /// - Parameter userId: The user ID to delete logs for
    /// - Returns: The number of logs deleted, or 0 if there was an error
    func deleteAllLogsForUser(userId: Int) -> Int {
        return swearLogRepository.deleteAllForUser(userId: userId)
    }
    
    /// Get logs for a specific date range
    /// - Parameters:
    ///   - userId: The user ID to get logs for
    ///   - startDate: Beginning of the date range
    ///   - endDate: End of the date range
    /// - Returns: Array of logs within the date range, empty array if none or if there was an error
    func getLogsInDateRange(userId: Int, startDate: Date, endDate: Date) -> [SwearLog] {
        return swearLogRepository.getLogsInDateRange(userId: userId, startDate: startDate, endDate: endDate)
    }
    
    /// Mark a swear event as "worth it" or not
    /// - Parameters:
    ///   - logId: The ID of the log to update
    ///   - worthIt: Whether the swear was worth it
    /// - Returns: True if the update was successful, false otherwise
    func updateWorthIt(logId: Int, worthIt: Bool) -> Bool {
        guard var log = swearLogRepository.getById(logId) else {
            print("Swear log not found.")
            return false
        }
        
        log.worthIt = worthIt
        return swearLogRepository.update(log)
    }
}
