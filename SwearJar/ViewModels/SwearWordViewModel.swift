//
//  SwearWordViewModel.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import Combine

/// ViewModel for managing swear word-related data and operations
class SwearWordViewModel: ObservableObject {
    
    // MARK: - Properties
    
    @Published var swearWords: [SwearWord] = []
    @Published var mostSevereWords: [SwearWord] = []
    
    private let swearWordService: SwearWordService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    init(swearWordService: SwearWordService = SwearWordService()) {
        self.swearWordService = swearWordService
        fetchAllSwearWords()
        fetchMostSevereWords()
    }
    
    // MARK: - Dictionary Management
    
    /// Add a new swear word to the dictionary
    /// - Parameters:
    ///   - word: The text of the swear word
    ///   - severity: The severity level of the swear word
    func addSwearWord(word: String, severity: SwearWord.Severity) {
        if let newWord = swearWordService.addSwearWord(word: word, severity: severity) {
            swearWords.append(newWord)
            fetchMostSevereWords() // Update severe words if necessary
        } else {
            print("Failed to add swear word.")
        }
    }
    
    /// Update an existing swear word's severity
    /// - Parameters:
    ///   - wordId: The ID of the swear word to update
    ///   - newSeverity: The new severity level
    func updateSwearWordSeverity(wordId: Int, newSeverity: SwearWord.Severity) {
        if swearWordService.updateSwearWordSeverity(wordId: wordId, newSeverity: newSeverity) {
            fetchAllSwearWords()
            fetchMostSevereWords() // Update severe words if necessary
        } else {
            print("Failed to update swear word severity.")
        }
    }
    
    /// Remove a swear word from the dictionary
    /// - Parameter wordId: The ID of the swear word to remove
    func removeSwearWord(wordId: Int) {
        if swearWordService.removeSwearWord(wordId: wordId) {
            swearWords.removeAll { $0.id == wordId }
            fetchMostSevereWords() // Update severe words if necessary
        } else {
            print("Failed to remove swear word.")
        }
    }
    
    // MARK: - Analytics
    
    /// Fetch all swear words in the dictionary
    private func fetchAllSwearWords() {
        swearWords = swearWordService.getAllSwearWords()
    }
    
    /// Fetch the most severe swear words
    private func fetchMostSevereWords() {
        mostSevereWords = swearWordService.getMostSevereWords()
    }
    
    // MARK: - Extended Functionality
    
    /// Search for swear words matching the given text
    /// - Parameter searchText: The text to search for
    /// - Returns: Array of matching swear words
    func searchWords(text searchText: String) -> [SwearWord] {
        return swearWordService.searchWords(text: searchText)
    }
    
    /// Get the count of swear words in the dictionary
    /// - Parameter includeCustom: Whether to include custom words in the count
    /// - Returns: The number of words
    func getWordCount(includeCustom: Bool = true) -> Int {
        return swearWordService.getWordCount(includeCustom: includeCustom)
    }
    
    /// Add default swear words to the dictionary
    /// - Returns: The number of words added
    func seedDefaultWords() -> Int {
        let count = swearWordService.seedDefaultWords()
        fetchAllSwearWords() // Refresh the word list
        fetchMostSevereWords() // Update severe words if necessary
        return count
    }
    
    /// Get only standard (non-custom) swear words
    /// - Returns: Array of standard swear words
    func getStandardWords() -> [SwearWord] {
        return swearWordService.getStandardWords()
    }
    
    /// Get only custom swear words
    /// - Returns: Array of custom swear words
    func getCustomWords() -> [SwearWord] {
        return swearWordService.getCustomWords()
    }
}
