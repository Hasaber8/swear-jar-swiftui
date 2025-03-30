//
//  SwearWord.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Represents a swear word in the dictionary
struct SwearWord: Identifiable, Codable {
    /// Database ID for the word
    var id: Int?
    
    /// The actual swear word text
    var word: String
    
    /// Severity level of the word
    var severity: Severity
    
    /// Default fine amount for using this word
    var defaultFine: Double
    
    /// Whether this is a custom word added by a user
    var isCustom: Bool
    
    /// Severity levels for swear words
    enum Severity: String, Codable, CaseIterable {
        case mild
        case moderate
        case severe
        
        /// Returns a suggested fine amount based on severity
        var suggestedFine: Double {
            switch self {
            case .mild:
                return 0.25
            case .moderate:
                return 0.50
            case .severe:
                return 1.00
            }
        }
        
        /// Returns a display-friendly name for the severity level
        var displayName: String {
            switch self {
            case .mild:
                return "Mild"
            case .moderate:
                return "Moderate"
            case .severe:
                return "Severe"
            }
        }
        
        /// Returns a color identifier for UI representation
        var colorIdentifier: String {
            switch self {
            case .mild:
                return "severity.mild"  // These would be defined in Assets
            case .moderate:
                return "severity.moderate"
            case .severe:
                return "severity.severe"
            }
        }
    }
    
    /// Creates a new SwearWord with default values
    init(id: Int? = nil,
         word: String,
         severity: Severity,
         defaultFine: Double? = nil,
         isCustom: Bool = false) {
        
        self.id = id
        self.word = word
        self.severity = severity
        self.defaultFine = defaultFine ?? severity.suggestedFine
        self.isCustom = isCustom
    }
    
    /// Database table name for the SwearWord model
    static let tableName = "swear_dictionary"
    
    /// Column names corresponding to the database schema
    enum CodingKeys: String, CodingKey {
        case id = "word_id"
        case word
        case severity
        case defaultFine = "default_fine"
        case isCustom = "is_custom"
    }
}

// MARK: - GRDB Extensions
extension SwearWord: FetchableRecord, TableRecord, PersistableRecord {
    /// Define the table name for GRDB operations
    static var databaseTableName: String { tableName }
    
    /// Initialize from a database row
    init(row: Row) {
        id = row[CodingKeys.id.stringValue] as Int?
        word = row[CodingKeys.word.stringValue] as String
        
        if let severityString = row[CodingKeys.severity.stringValue] as String? {
            severity = Severity(rawValue: severityString) ?? .mild
        } else {
            severity = .mild
        }
        
        defaultFine = row[CodingKeys.defaultFine.stringValue] as Double
        isCustom = row[CodingKeys.isCustom.stringValue] as Bool
    }
    
    /// Encode to a persistence container
    func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.word.stringValue] = word
        container[CodingKeys.severity.stringValue] = severity.rawValue
        container[CodingKeys.defaultFine.stringValue] = defaultFine
        container[CodingKeys.isCustom.stringValue] = isCustom
        
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
