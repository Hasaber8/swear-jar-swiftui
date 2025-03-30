//
//  SwearLogViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing swear log-related data and operations
class SwearLogViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var recentLogs: [SwearLog] = []
    @Published var totalFineForToday: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let swearLogService: SwearLogService
    private var userId: Int?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    /// Initialize with optional user ID
    /// - Parameters:
    ///   - userId: Optional user ID to load logs for
    ///   - swearLogService: Service for swear log operations
    init(userId: Int? = nil, swearLogService: SwearLogService = SwearLogService()) {
        self.swearLogService = swearLogService
        self.userId = userId
        
        // If user ID is provided, fetch logs
        if let userId = userId {
            fetchLogData(userId: userId)
        }
    }
    
    /// Set the active user and fetch their log data
    /// - Parameter userId: The ID of the user to load logs for
    func setActiveUser(userId: Int) {
        self.userId = userId
        fetchLogData(userId: userId)
    }
    
    // MARK: - Data Management
    
    /// Fetch log data for a user
    /// - Parameter userId: The ID of the user to retrieve logs for
    private func fetchLogData(userId: Int) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let recentLogs = self.swearLogService.getRecentLogs(userId: userId)
            let totalFine = self.swearLogService.getTotalFineForDay(userId: userId, date: Date())
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.recentLogs = recentLogs
                self.totalFineForToday = totalFine
            }
        }
    }
    
    // MARK: - Logging Management
    
    /// Log a new swear event
    /// - Parameters:
    ///   - wordId: The ID of the swear word used
    ///   - mood: The mood during the event
    ///   - context: The context or situation of the event
    ///   - fineAmount: The fine amount for the swear event
    /// - Returns: The created log, or nil if creation failed
    func logSwearEvent(wordId: Int, mood: SwearLog.Mood?, context: String?, fineAmount: Double) -> SwearLog? {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return nil
        }
        
        isLoading = true
        
        let newLog = swearLogService.logSwearEvent(
            userId: userId,
            wordId: wordId,
            mood: mood,
            context: context,
            fineAmount: fineAmount
        )
        
        isLoading = false
        
        if let newLog = newLog {
            recentLogs.insert(newLog, at: 0)
            totalFineForToday += fineAmount
            return newLog
        } else {
            errorMessage = "Failed to log swear event"
            return nil
        }
    }
    
    /// Update a swear log entry
    /// - Parameter log: The log to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func updateLog(_ log: SwearLog) -> Bool {
        isLoading = true
        
        let success = swearLogService.updateLog(log)
        
        isLoading = false
        
        if success {
            if let index = recentLogs.firstIndex(where: { $0.id == log.id }) {
                recentLogs[index] = log
            }
            return true
        } else {
            errorMessage = "Failed to update log"
            return false
        }
    }
    
    /// Delete a log entry by ID
    /// - Parameter id: The ID of the log to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func deleteLog(id: Int) -> Bool {
        isLoading = true
        
        let success = swearLogService.deleteLog(id: id)
        
        isLoading = false
        
        if success {
            recentLogs.removeAll { $0.id == id }
            // Recalculate today's total if needed
            if let userId = userId {
                totalFineForToday = swearLogService.getTotalFineForDay(userId: userId, date: Date())
            }
            return true
        } else {
            errorMessage = "Failed to delete log"
            return false
        }
    }
    
    /// Mark a swear event as "worth it" or not
    /// - Parameters:
    ///   - logId: The ID of the log to update
    ///   - worthIt: Whether the swear was worth it
    /// - Returns: True if the update was successful, false otherwise
    func updateWorthIt(logId: Int, worthIt: Bool) -> Bool {
        isLoading = true
        
        let success = swearLogService.updateWorthIt(logId: logId, worthIt: worthIt)
        
        isLoading = false
        
        if success {
            if let index = recentLogs.firstIndex(where: { $0.id == logId }) {
                recentLogs[index].worthIt = worthIt
            }
            return true
        } else {
            errorMessage = "Failed to update 'worth it' status"
            return false
        }
    }
    
    // MARK: - Analytics
    
    /// Get logs for a specific date range
    /// - Parameters:
    ///   - startDate: Beginning of the date range
    ///   - endDate: End of the date range
    /// - Returns: Array of logs within the date range
    func getLogsInDateRange(startDate: Date, endDate: Date) -> [SwearLog] {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return []
        }
        
        return swearLogService.getLogsInDateRange(userId: userId, startDate: startDate, endDate: endDate)
    }
    
    /// Get logs for a specific day
    /// - Parameter date: The date to get logs for
    /// - Returns: Array of logs for the specified day
    func getLogsForDay(date: Date) -> [SwearLog] {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return []
        }
        
        return swearLogService.getLogsForDay(userId: userId, date: date)
    }
    
    /// Get the total fine amount for a specific day
    /// - Parameter date: The date to calculate fines for
    /// - Returns: The total fine amount for the specified day
    func getTotalFineForDay(date: Date) -> Double {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return 0.0
        }
        
        return swearLogService.getTotalFineForDay(userId: userId, date: date)
    }
    
    // MARK: - Helper Methods
    
    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Refresh log data for the current user
    func refreshData() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        fetchLogData(userId: userId)
    }
}
