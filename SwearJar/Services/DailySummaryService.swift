//
//  DailySummaryService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing daily summary-related operations
class DailySummaryService {
    
    // MARK: - Properties
    
    private let dailySummaryRepository: DailySummaryRepository
    
    // MARK: - Initialization
    
    init(dailySummaryRepository: DailySummaryRepository = DailySummaryRepository()) {
        self.dailySummaryRepository = dailySummaryRepository
    }
    
    // MARK: - Summary Management
    
    /// Generate or update a daily summary for a specific day
    /// - Parameters:
    ///   - userId: The user ID to generate a summary for
    ///   - date: The date to generate a summary for
    /// - Returns: The generated or updated summary, or nil if there was an error
    func generateSummary(userId: Int, date: Date) -> DailySummary? {
        return dailySummaryRepository.generateSummary(userId: userId, date: date)
    }
    
    /// Get a daily summary by user ID and date
    /// - Parameters:
    ///   - userId: The user ID to retrieve the summary for
    ///   - date: The date to retrieve the summary for
    /// - Returns: The daily summary if found, nil otherwise
    func getSummaryForDate(userId: Int, date: Date) -> DailySummary? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dailySummaryRepository.getByUserAndDate(userId: userId, date: dateString)
    }
    
    // MARK: - Analytics
    
    /// Get the total fine amount for a user over a time period
    /// - Parameters:
    ///   - userId: The user ID to calculate fines for
    ///   - timeFrame: Optional number of days to consider (nil = all time)
    /// - Returns: The total fine amount, or 0 if there's no data or if there was an error
    func getTotalFine(userId: Int, timeFrame: Int? = nil) -> Double {
        return dailySummaryRepository.getTotalFine(userId: userId, timeFrame: timeFrame)
    }
    
    /// Get the most common swear word for a user over a time period
    /// - Parameters:
    ///   - userId: The user ID to analyze
    ///   - timeFrame: Optional number of days to consider (nil = all time)
    /// - Returns: The ID of the most common word, or nil if there's no data or if there was an error
    func getMostCommonWord(userId: Int, timeFrame: Int? = nil) -> Int? {
        return dailySummaryRepository.getMostCommonWord(userId: userId, timeFrame: timeFrame)
    }
    
    /// Get all daily summaries for a user
    /// - Parameter userId: The user ID to get summaries for
    /// - Returns: Array of daily summaries, empty array if none or if there was an error
    func getAllForUser(userId: Int) -> [DailySummary] {
        return dailySummaryRepository.getAllForUser(userId: userId)
    }
    
    /// Get summaries for a date range
    /// - Parameters:
    ///   - userId: The user ID to get summaries for
    ///   - startDate: The beginning of the date range
    ///   - endDate: The end of the date range
    /// - Returns: Array of summaries within the date range, empty array if none or if there was an error
    func getSummariesInDateRange(userId: Int, startDate: Date, endDate: Date) -> [DailySummary] {
        return dailySummaryRepository.getSummariesInDateRange(userId: userId, startDate: startDate, endDate: endDate)
    }
    
    /// Get all clean days for a user
    /// - Parameter userId: The user ID to get clean days for
    /// - Returns: Array of summaries for clean days, empty array if none or if there was an error
    func getCleanDays(userId: Int) -> [DailySummary] {
        return dailySummaryRepository.getCleanDays(userId: userId)
    }
    
    /// Get the count of clean days for a user
    /// - Parameter userId: The user ID to count clean days for
    /// - Returns: The number of clean days, or 0 if there was an error
    func getCleanDayCount(userId: Int) -> Int {
        return dailySummaryRepository.getCleanDayCount(userId: userId)
    }
    
    /// Generate a summary for today if it doesn't exist
    /// - Parameter userId: The user ID to generate a summary for
    /// - Returns: The generated or existing summary, or nil if there was an error
    func ensureTodaySummary(userId: Int) -> DailySummary? {
        return dailySummaryRepository.ensureTodaySummary(userId: userId)
    }
}
