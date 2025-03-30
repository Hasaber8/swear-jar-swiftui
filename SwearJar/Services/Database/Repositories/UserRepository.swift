//
//  UserRepository.swift
//  SwearJar
//
//  Created for SwearJar app
//

import Foundation
import GRDB

/// Repository for managing User entities in the database
class UserRepository {
    
    // MARK: - Properties
    
    /// Database access point
    private let dbQueue: DatabaseQueue
    
    // MARK: - Initialization
    
    /// Initialize with database connection
    init(dbQueue: DatabaseQueue = DatabaseManager.shared.dbQueue) {
        self.dbQueue = dbQueue
    }
    
    // MARK: - CRUD Operations
    
    /// Create a new user in the database
    /// - Parameter user: The user to create
    /// - Returns: The created user with ID assigned, or nil if creation failed
    func create(_ user: User) -> User? {
        do {
            var newUser = user
            try dbQueue.write { db in
                try newUser.insert(db)
            }
            
            // If the ID is still nil after insert, try to fetch the user by username
            if newUser.id == nil {
                newUser = getByUsername(user.username) ?? newUser
                print("DEBUG: After insert, user ID: \(newUser.id)")
            }
            
            return newUser
        } catch {
            print("Error creating user: \(error)")
            return nil
        }
    }
    
    /// Retrieve a user by ID
    /// - Parameter id: The ID of the user to retrieve
    /// - Returns: The user if found, nil otherwise
    func getById(_ id: Int) -> User? {
        do {
            return try dbQueue.read { db in
                try User.fetchOne(db, key: id)
            }
        } catch {
            print("Error fetching user by ID: \(error)")
            return nil
        }
    }
    
    /// Retrieve a user by username
    /// - Parameter username: The username to search for
    /// - Returns: The user if found, nil otherwise
    func getByUsername(_ username: String) -> User? {
        do {
            return try dbQueue.read { db in
                try User
                    .filter(Column(User.CodingKeys.username.stringValue) == username)
                    .fetchOne(db)
            }
        } catch {
            print("Error fetching user by username: \(error)")
            return nil
        }
    }
    
    /// Retrieve all users
    /// - Returns: Array of all users, empty array if none or if there was an error
    func getAll() -> [User] {
        do {
            return try dbQueue.read { db in
                try User.fetchAll(db)
            }
        } catch {
            print("Error fetching all users: \(error)")
            return []
        }
    }
    
    /// Update an existing user
    /// - Parameter user: The user to update (must have an ID)
    /// - Returns: True if the update was successful, false otherwise
    func update(_ user: User) -> Bool {
        guard user.id != nil else {
            print("Error updating user: ID is nil")
            return false
        }
        
        do {
            try dbQueue.write { db in
                try user.update(db)
            }
            return true
        } catch {
            print("Error updating user: \(error)")
            return false
        }
    }
    
    /// Delete a user by ID
    /// - Parameter id: The ID of the user to delete
    /// - Returns: True if the deletion was successful, false otherwise
    func delete(id: Int) -> Bool {
        do {
            try dbQueue.write { db in
                _ = try User.deleteOne(db, key: id)
            }
            return true
        } catch {
            print("Error deleting user: \(error)")
            return false
        }
    }
    
    // MARK: - Additional Methods
    
    /// Update the user's streak information
    /// - Parameters:
    ///   - userId: The ID of the user to update
    ///   - streakDays: The new streak days count
    /// - Returns: True if the update was successful, false otherwise
    func updateStreak(userId: Int, streakDays: Int) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: "UPDATE \(User.tableName) SET \(User.CodingKeys.streakDays.stringValue) = ? WHERE \(User.CodingKeys.id.stringValue) = ?",
                    arguments: [streakDays, userId]
                )
            }
            return true
        } catch {
            print("Error updating user streak: \(error)")
            return false
        }
    }
    
    /// Update the last active timestamp for a user
    /// - Parameter userId: The ID of the user to update
    /// - Returns: True if the update was successful, false otherwise
    func updateLastActive(userId: Int) -> Bool {
        do {
            let now = Date()
            try dbQueue.write { db in
                try db.execute(
                    sql: "UPDATE \(User.tableName) SET \(User.CodingKeys.lastActive.stringValue) = ? WHERE \(User.CodingKeys.id.stringValue) = ?",
                    arguments: [now, userId]
                )
            }
            return true
        } catch {
            print("Error updating last active time: \(error)")
            return false
        }
    }
    
    /// Update the swear count and fine total after a new swear is logged
    /// - Parameters:
    ///   - userId: The ID of the user to update
    ///   - fineAmount: The fine amount to add
    /// - Returns: True if the update was successful, false otherwise
    func incrementSwearStats(userId: Int, fineAmount: Double) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: """
                    UPDATE \(User.tableName) 
                    SET \(User.CodingKeys.totalSwears.stringValue) = \(User.CodingKeys.totalSwears.stringValue) + 1,
                        \(User.CodingKeys.totalFine.stringValue) = \(User.CodingKeys.totalFine.stringValue) + ?
                    WHERE \(User.CodingKeys.id.stringValue) = ?
                    """,
                    arguments: [fineAmount, userId]
                )
            }
            return true
        } catch {
            print("Error incrementing swear stats: \(error)")
            return false
        }
    }
    
    /// Check if a username is already taken
    /// - Parameter username: The username to check
    /// - Returns: True if the username is already taken, false otherwise
    func isUsernameTaken(_ username: String) -> Bool {
        do {
            let count = try dbQueue.read { db in
                try User
                    .filter(Column(User.CodingKeys.username.stringValue) == username)
                    .fetchCount(db)
            }
            return count > 0
        } catch {
            print("Error checking if username is taken: \(error)")
            return false
        }
    }
}
