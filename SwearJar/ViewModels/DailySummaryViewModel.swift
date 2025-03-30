//
//  DailySummaryViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing daily summary-related data and operations
class DailySummaryViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var todaySummary: DailySummary?
    @Published var recentSummaries: [DailySummary] = []
    @Published var cleanDays: Int = 0
    @Published var totalFine: Double = 0.0
    @Published var mostCommonWord: Int?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let dailySummaryService: DailySummaryService
    private var userId: Int?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    /// Initialize with optional user ID
    /// - Parameters:
    ///   - userId: Optional user ID to load summary data for
    ///   - dailySummaryService: Service for daily summary operations
    init(userId: Int? = nil, dailySummaryService: DailySummaryService = DailySummaryService()) {
        self.dailySummaryService = dailySummaryService
        self.userId = userId
        
        // If user ID is provided, fetch summary data
        if let userId = userId {
            fetchSummaryData(userId: userId)
        }
    }
    
    /// Set the active user and fetch their summary data
    /// - Parameter userId: The ID of the user to load summary data for
    func setActiveUser(userId: Int) {
        self.userId = userId
        fetchSummaryData(userId: userId)
    }
    
    // MARK: - Data Management
    
    /// Fetch all summary data for a user
    /// - Parameter userId: The ID of the user to retrieve summary data for
    private func fetchSummaryData(userId: Int) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Ensure today's summary exists
            let today = self.dailySummaryService.ensureTodaySummary(userId: userId)
            
            // Get recent summaries (last 30 days)
            let calendar = Calendar.current
            let endDate = Date()
            let startDate = calendar.date(byAdding: .day, value: -30, to: endDate)!
            let recentSummaries = self.dailySummaryService.getSummariesInDateRange(
                userId: userId,
                startDate: startDate,
                endDate: endDate
            )
            
            // Get clean day count
            let cleanDays = self.dailySummaryService.getCleanDayCount(userId: userId)
            
            // Get total fine
            let totalFine = self.dailySummaryService.getTotalFine(userId: userId)
            
            // Get most common word
            let mostCommonWord = self.dailySummaryService.getMostCommonWord(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.todaySummary = today
                self.recentSummaries = recentSummaries
                self.cleanDays = cleanDays
                self.totalFine = totalFine
                self.mostCommonWord = mostCommonWord
            }
        }
    }
    
    /// Refresh today's summary data
    func refreshTodaySummary() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let today = self.dailySummaryService.generateSummary(userId: userId, date: Date())
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let today = today {
                    self.todaySummary = today
                    
                    // Update in recent summaries list if it exists
                    if let index = self.recentSummaries.firstIndex(where: { $0.id == today.id }) {
                        self.recentSummaries[index] = today
                    } else {
                        self.recentSummaries.insert(today, at: 0)
                    }
                } else {
                    self.errorMessage = "Failed to generate today's summary"
                }
            }
        }
    }
    
    /// Get summary for a specific date
    /// - Parameter date: The date to get the summary for
    /// - Returns: The summary for the specified date, or nil if not found
    func getSummaryForDate(_ date: Date) -> DailySummary? {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return nil
        }
        
        return dailySummaryService.getSummaryForDate(userId: userId, date: date)
    }
    
    /// Get summaries for the specified date range
    /// - Parameters:
    ///   - startDate: The beginning of the date range
    ///   - endDate: The end of the date range
    /// - Returns: Array of summaries within the date range
    func getSummariesForDateRange(startDate: Date, endDate: Date) -> [DailySummary] {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return []
        }
        
        return dailySummaryService.getSummariesInDateRange(
            userId: userId,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    // MARK: - Helper Methods
    
    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Check if the current day is clean (no swears)
    var isTodayClean: Bool {
        return todaySummary?.isCleanDay ?? true
    }
    
    /// Get the percentage of clean days
    var cleanDayPercentage: Double {
        guard !recentSummaries.isEmpty else { return 0.0 }
        return Double(cleanDays) / Double(recentSummaries.count) * 100.0
    }
    
    /// Get the current month's total fine amount
    var currentMonthFine: Double {
        guard let userId = userId else { return 0.0 }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        )!
        
        let summaries = dailySummaryService.getSummariesInDateRange(
            userId: userId,
            startDate: startOfMonth,
            endDate: now
        )
        
        return summaries.reduce(0.0) { $0 + $1.totalFine }
    }
}
