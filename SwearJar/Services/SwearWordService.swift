//
//  SwearWordService.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation

/// Service for managing swear word-related operations
class SwearWordService {
    
    // MARK: - Properties
    
    private let swearWordRepository: SwearWordRepository
    
    // MARK: - Initialization
    
    init(swearWordRepository: SwearWordRepository = SwearWordRepository()) {
        self.swearWordRepository = swearWordRepository
    }
    
    // MARK: - Dictionary Management
    
    /// Add a new swear word to the dictionary
    /// - Parameters:
    ///   - word: The text of the swear word
    ///   - severity: The severity level of the swear word
    /// - Returns: The created swear word, or nil if creation failed
    func addSwearWord(word: String, severity: SwearWord.Severity) -> SwearWord? {
        // Check if the word already exists
        if let existingWord = swearWordRepository.getByWord(word) {
            print("Swear word already exists: \(existingWord)")
            return nil
        }
        
        // Create a new swear word
        let newSwearWord = SwearWord(word: word, severity: severity)
        return swearWordRepository.create(newSwearWord)
    }
    
    /// Update an existing swear word's severity
    /// - Parameters:
    ///   - wordId: The ID of the swear word to update
    ///   - newSeverity: The new severity level
    /// - Returns: True if the update was successful, false otherwise
    func updateSwearWordSeverity(wordId: Int, newSeverity: SwearWord.Severity) -> Bool {
        guard var swearWord = swearWordRepository.getById(wordId) else {
            print("Swear word not found.")
            return false
        }
        
        swearWord.severity = newSeverity
        return swearWordRepository.update(swearWord)
    }
    
    /// Remove a swear word from the dictionary
    /// - Parameter wordId: The ID of the swear word to remove
    /// - Returns: True if the deletion was successful, false otherwise
    func removeSwearWord(wordId: Int) -> Bool {
        return swearWordRepository.delete(id: wordId)
    }
    
    // MARK: - Analytics
    
    /// Get the most severe swear words
    /// - Returns: Array of the most severe swear words
    func getMostSevereWords() -> [SwearWord] {
        return swearWordRepository.getBySeverity(.severe)
    }
    
    /// Get all swear words in the dictionary
    /// - Returns: Array of all swear words
    func getAllSwearWords() -> [SwearWord] {
        return swearWordRepository.getAll()
    }
    
    /// Search for swear words containing the given text
    /// - Parameter searchText: The text to search for
    /// - Returns: Array of matching words, empty array if none or if there was an error
    func searchWords(text searchText: String) -> [SwearWord] {
        return swearWordRepository.search(text: searchText)
    }
    
    /// Get the count of swear words in the dictionary
    /// - Parameter includeCustom: Whether to include custom words in the count
    /// - Returns: The number of words, or 0 if there was an error
    func getWordCount(includeCustom: Bool = true) -> Int {
        return swearWordRepository.getCount(includeCustom: includeCustom)
    }
    
    /// Add a set of default swear words to the dictionary
    /// - Returns: The number of words added, or 0 if there was an error
    func seedDefaultWords() -> Int {
        return swearWordRepository.seedDefaultWords()
    }
    
    /// Get standard swear words (excluding custom ones)
    /// - Returns: Array of standard swear words
    func getStandardWords() -> [SwearWord] {
        return swearWordRepository.getAll(includeCustom: false)
    }
    
    /// Get custom swear words added by users
    /// - Returns: Array of custom swear words
    func getCustomWords() -> [SwearWord] {
        let allWords = swearWordRepository.getAll()
        return allWords.filter { $0.isCustom }
    }
}
