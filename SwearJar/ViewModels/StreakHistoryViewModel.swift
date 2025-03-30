//
//  StreakHistoryViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing streak history-related data and operations
class StreakHistoryViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var currentStreak: StreakHistory?
    @Published var longestStreak: StreakHistory?
    @Published var streakHistory: [StreakHistory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let streakHistoryService: StreakHistoryService
    private var userId: Int?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    /// Initialize with optional user ID
    /// - Parameters:
    ///   - userId: Optional user ID to load streak data for
    ///   - streakHistoryService: Service for streak history operations
    init(userId: Int? = nil, streakHistoryService: StreakHistoryService = StreakHistoryService()) {
        self.streakHistoryService = streakHistoryService
        self.userId = userId
        
        // If user ID is provided, fetch streak data
        if let userId = userId {
            fetchStreakData(userId: userId)
        }
    }
    
    /// Set the active user and fetch their streak data
    /// - Parameter userId: The ID of the user to load streak data for
    func setActiveUser(userId: Int) {
        self.userId = userId
        fetchStreakData(userId: userId)
    }
    
    // MARK: - Streak Management
    
    /// Fetch all streak data for a user
    /// - Parameter userId: The ID of the user to retrieve streak data for
    private func fetchStreakData(userId: Int) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Fetch current streak
            let currentStreak = self.streakHistoryService.getCurrentStreak(userId: userId)
            
            // Fetch longest streak
            let longestStreak = self.streakHistoryService.getLongestStreak(userId: userId)
            
            // Fetch streak history
            let streakHistory = self.streakHistoryService.getAllForUser(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.currentStreak = currentStreak
                self.longestStreak = longestStreak
                self.streakHistory = streakHistory
            }
        }
    }
    
    /// Start a new streak for the current user
    func startNewStreak() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let newStreak = self.streakHistoryService.startNewStreak(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let newStreak = newStreak {
                    self.currentStreak = newStreak
                    self.streakHistory.insert(newStreak, at: 0)
                } else {
                    self.errorMessage = "Failed to start new streak"
                }
            }
        }
    }
    
    /// End the current streak for the active user
    func endCurrentStreak() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let success = self.streakHistoryService.endCurrentStreak(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    // If successful, current streak will end, so set to nil
                    if let currentStreak = self.currentStreak {
                        var endedStreak = currentStreak
                        endedStreak.endDate = Date()
                        endedStreak.isCurrent = false
                        
                        // Update in history list
                        if let index = self.streakHistory.firstIndex(where: { $0.id == endedStreak.id }) {
                            self.streakHistory[index] = endedStreak
                        }
                    }
                    self.currentStreak = nil
                } else {
                    self.errorMessage = "Failed to end current streak"
                }
            }
        }
    }
    
    /// Increment the current streak by one day
    func incrementStreak() {
        guard let userId = userId else {
            errorMessage = "No active user selected"
            return
        }
        
        isLoading = true
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            let updatedStreak = self.streakHistoryService.incrementStreak(userId: userId)
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let updatedStreak = updatedStreak {
                    self.currentStreak = updatedStreak
                    
                    // Update in history list
                    if let index = self.streakHistory.firstIndex(where: { $0.id == updatedStreak.id }) {
                        self.streakHistory[index] = updatedStreak
                    } else {
                        // New streak was created
                        self.streakHistory.insert(updatedStreak, at: 0)
                    }
                    
                    // Check if this is now the longest streak
                    if let longest = self.longestStreak,
                       updatedStreak.streakLength > longest.streakLength {
                        self.longestStreak = updatedStreak
                    }
                } else {
                    self.errorMessage = "Failed to increment streak"
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clear any error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Check if the user has an active streak
    var hasActiveStreak: Bool {
        return currentStreak != nil
    }
    
    /// Get the current streak length
    var currentStreakLength: Int {
        return currentStreak?.streakLength ?? 0
    }
    
    /// Get the longest streak length
    var longestStreakLength: Int {
        return longestStreak?.streakLength ?? 0
    }
}
