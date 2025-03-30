//
//  DatabaseManager.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Manages the database connection and structure
class DatabaseManager {
    // MARK: - Singleton
    
    /// Shared database manager instance
    static let shared = DatabaseManager()
    
    // MARK: - Properties
    
    /// Database connection queue
    private(set) var dbQueue: DatabaseQueue!
    
    // Database structure version
    private let schemaVersion = 1
    
    // MARK: - Initialization
    
    private init() {
        setupDatabase()
    }
    
    // MARK: - Database Setup
    
    /// Set up the database
    private func setupDatabase() {
        do {
            // Get the URL for the database file
            let fileManager = FileManager.default
            let folderURL = try fileManager.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            let dbURL = folderURL.appendingPathComponent("swearjar.sqlite")
            
            // Database configuration
            var config = Configuration()
            
            // Enable foreign keys
            config.foreignKeysEnabled = true
            
            // Set up tracing for debug builds
            #if DEBUG
            config.prepareDatabase { db in
                db.trace { print("SQL: \($0)") }
            }
            #endif
            
            // Create the database connection
            dbQueue = try DatabaseQueue(path: dbURL.path, configuration: config)
            
            // Perform migrations
            try migrateDatabase()
            
        } catch {
            fatalError("Failed to setup database: \(error)")
        }
    }
    
    /// Migrate database to latest schema
    private func migrateDatabase() throws {
        try dbQueue.write { db in
            if try db.tableExists("users") {
                // Database already exists, check for migrations
                // Handle migrations in future versions
            } else {
                // Fresh database, create schema
                try createDatabaseSchema(db)
            }
        }
    }
    
    /// Create initial database schema
    private func createDatabaseSchema(_ db: Database) throws {
        // Users table
        try db.create(table: User.tableName) { t in
            t.column(User.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(User.CodingKeys.username.stringValue, .text).notNull()
            t.column(User.CodingKeys.displayName.stringValue, .text)
            t.column(User.CodingKeys.avatarPath.stringValue, .text)
            t.column(User.CodingKeys.createdAt.stringValue, .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            t.column(User.CodingKeys.lastActive.stringValue, .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            t.column(User.CodingKeys.streakDays.stringValue, .integer).notNull().defaults(to: 0)
            t.column(User.CodingKeys.totalSwears.stringValue, .integer).notNull().defaults(to: 0)
            t.column(User.CodingKeys.totalFine.stringValue, .double).notNull().defaults(to: 0.0)
        }
        
        // Swear dictionary table
        try db.create(table: SwearWord.tableName) { t in
            t.column(SwearWord.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(SwearWord.CodingKeys.word.stringValue, .text).notNull().unique()
            t.column(SwearWord.CodingKeys.severity.stringValue, .text).notNull()
                .check(sql: "severity IN ('mild', 'moderate', 'severe')")
            t.column(SwearWord.CodingKeys.defaultFine.stringValue, .double).notNull()
            t.column(SwearWord.CodingKeys.isCustom.stringValue, .boolean).notNull().defaults(to: false)
        }
        
        // User words table
        try db.create(table: UserWord.tableName) { t in
            t.column(UserWord.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(UserWord.CodingKeys.userId.stringValue, .integer).notNull()
                .references(User.tableName, column: User.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(UserWord.CodingKeys.wordId.stringValue, .integer).notNull()
                .references(SwearWord.tableName, column: SwearWord.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(UserWord.CodingKeys.customFine.stringValue, .double)
            t.column(UserWord.CodingKeys.isActive.stringValue, .boolean).notNull().defaults(to: true)
            t.uniqueKey([UserWord.CodingKeys.userId.stringValue, UserWord.CodingKeys.wordId.stringValue])
        }
        
        // Swear logs table
        try db.create(table: SwearLog.tableName) { t in
            t.column(SwearLog.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(SwearLog.CodingKeys.userId.stringValue, .integer).notNull()
                .references(User.tableName, column: User.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(SwearLog.CodingKeys.wordId.stringValue, .integer).notNull()
                .references(SwearWord.tableName, column: SwearWord.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(SwearLog.CodingKeys.timestamp.stringValue, .datetime).notNull().defaults(sql: "CURRENT_TIMESTAMP")
            t.column(SwearLog.CodingKeys.mood.stringValue, .text)
                .check(sql: "mood IN ('angry', 'frustrated', 'surprised', 'amused', 'stressed', 'other')")
            t.column(SwearLog.CodingKeys.worthIt.stringValue, .boolean)
            t.column(SwearLog.CodingKeys.context.stringValue, .text)
            t.column(SwearLog.CodingKeys.fineAmount.stringValue, .double).notNull()
            t.column(SwearLog.CodingKeys.location.stringValue, .text)
        }
        
        // User settings table
        try db.create(table: UserSettings.tableName) { t in
            t.column(UserSettings.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(UserSettings.CodingKeys.userId.stringValue, .integer).notNull().unique()
                .references(User.tableName, column: User.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(UserSettings.CodingKeys.notificationsEnabled.stringValue, .boolean).notNull().defaults(to: true)
            t.column(UserSettings.CodingKeys.darkMode.stringValue, .boolean).notNull().defaults(to: true)
            t.column(UserSettings.CodingKeys.reminderTime.stringValue, .text)
            t.column(UserSettings.CodingKeys.shareStats.stringValue, .boolean).notNull().defaults(to: false)
            t.column(UserSettings.CodingKeys.autoLocation.stringValue, .boolean).notNull().defaults(to: false)
        }
        
        // Streak history table
        try db.create(table: StreakHistory.tableName) { t in
            t.column(StreakHistory.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(StreakHistory.CodingKeys.userId.stringValue, .integer).notNull()
                .references(User.tableName, column: User.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(StreakHistory.CodingKeys.streakLength.stringValue, .integer).notNull()
            t.column(StreakHistory.CodingKeys.startDate.stringValue, .datetime).notNull()
            t.column(StreakHistory.CodingKeys.endDate.stringValue, .datetime)
            t.column(StreakHistory.CodingKeys.isCurrent.stringValue, .boolean).notNull().defaults(to: true)
        }
        
        // Daily summaries table
        try db.create(table: DailySummary.tableName) { t in
            t.column(DailySummary.CodingKeys.id.stringValue, .integer).primaryKey(autoincrement: true)
            t.column(DailySummary.CodingKeys.userId.stringValue, .integer).notNull()
                .references(User.tableName, column: User.CodingKeys.id.stringValue, onDelete: .cascade)
            t.column(DailySummary.CodingKeys.date.stringValue, .text).notNull()
            t.column(DailySummary.CodingKeys.swearCount.stringValue, .integer).notNull().defaults(to: 0)
            t.column(DailySummary.CodingKeys.totalFine.stringValue, .double).notNull().defaults(to: 0.0)
            t.column(DailySummary.CodingKeys.mostCommonWordId.stringValue, .integer)
                .references(SwearWord.tableName, column: SwearWord.CodingKeys.id.stringValue, onDelete: .setNull)
            t.column(DailySummary.CodingKeys.mostCommonMood.stringValue, .text)
            t.column(DailySummary.CodingKeys.isCleanDay.stringValue, .boolean).notNull().defaults(to: true)
            t.uniqueKey([DailySummary.CodingKeys.userId.stringValue, DailySummary.CodingKeys.date.stringValue])
        }
        
        // Create indexes for performance optimization
        try db.create(index: "idx_swear_logs_user_timestamp", on: SwearLog.tableName, 
                     columns: [SwearLog.CodingKeys.userId.stringValue, SwearLog.CodingKeys.timestamp.stringValue])
        try db.create(index: "idx_swear_logs_word_id", on: SwearLog.tableName, 
                     columns: [SwearLog.CodingKeys.wordId.stringValue])
        try db.create(index: "idx_daily_summaries_user_date", on: DailySummary.tableName, 
                     columns: [DailySummary.CodingKeys.userId.stringValue, DailySummary.CodingKeys.date.stringValue])
        try db.create(index: "idx_user_words_user_id", on: UserWord.tableName, 
                     columns: [UserWord.CodingKeys.userId.stringValue])
    }
    
    // MARK: - Helper Methods
    
    /// Reset the database (for development and testing)
    func resetDatabase() throws {
        try dbQueue.write { db in
            // Drop all tables
            try db.drop(table: DailySummary.tableName)
            try db.drop(table: StreakHistory.tableName)
            try db.drop(table: UserSettings.tableName)
            try db.drop(table: SwearLog.tableName)
            try db.drop(table: UserWord.tableName)
            try db.drop(table: SwearWord.tableName)
            try db.drop(table: User.tableName)
            
            // Recreate schema
            try createDatabaseSchema(db)
        }
    }
}
