//
//  BuddyListRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62

/// Registry for managing buddy lists with database persistence.
///
/// This actor manages buddy list state with persistence to the database.
/// It maintains an in-memory cache for performance while ensuring all
/// changes are persisted to the database.
public actor BuddyListRegistry {

    public static let shared = BuddyListRegistry()

    /// In-memory buddy list cache indexed by character ID
    private var cache: [Character.ID: [Buddy]] = [:]
    
    /// In-memory pending buddy requests indexed by the character who will receive the request
    private var pendingRequests: [Character.ID: [PendingBuddyRequest]] = [:]

    private init() { }

    // MARK: - Buddy List Operations
    
    /// Load buddies from database for a character
    public func loadBuddies(for characterID: Character.ID, from database: some ModelStorage) async throws -> [Buddy] {
        // Check cache first
        if let cached = cache[characterID] {
            return cached
        }
        
        // Load from database
        let predicate = FetchRequest.Predicate.relationship(.init(name: "character", value: characterID))
        let buddies = try await database.fetch(Buddy.self, predicate: predicate)
        
        // Cache the results
        cache[characterID] = buddies
        
        return buddies
    }
    
    /// Returns the count of confirmed (non-pending) buddies
    public func buddyCount(for characterID: Character.ID, in database: some ModelStorage) async throws -> Int {
        let buddies = try await loadBuddies(for: characterID, from: database)
        return buddies.filter { !$0.pending }.count
    }
    
    /// Checks if the buddy list is at or above capacity
    public func isFull(_ characterID: Character.ID, capacity: UInt8, in database: some ModelStorage) async throws -> Bool {
        try await buddyCount(for: characterID, in: database) >= Int(capacity)
    }

    /// Add a buddy to a character's list (persists to database)
    public func addBuddy(_ buddy: Buddy, to characterID: Character.ID, in database: some ModelStorage) async throws -> Bool {
        // Check if already exists
        var buddies = try await loadBuddies(for: characterID, from: database)
        guard !buddies.contains(where: { $0.buddyID == buddy.buddyID }) else {
            return false
        }
        
        // Save to database
        try await database.insert(buddy)
        
        // Update cache
        buddies.append(buddy)
        cache[characterID] = buddies
        
        return true
    }

    /// Remove a buddy from a character's list (persists to database)
    public func removeBuddy(buddyID: Character.Index, from characterID: Character.ID, in database: some ModelStorage) async throws -> Bool {
        var buddies = try await loadBuddies(for: characterID, from: database)
        
        guard let index = buddies.firstIndex(where: { $0.buddyID == buddyID }) else {
            return false
        }
        
        let buddyToRemove = buddies[index]
        
        // Delete from database
        try await database.delete(Buddy.self, for: buddyToRemove.id)
        
        // Update cache
        buddies.remove(at: index)
        cache[characterID] = buddies
        
        return true
    }
    
    /// Check if a buddy is already in the list
    public func contains(buddyID: Character.Index, in characterID: Character.ID, database: some ModelStorage) async throws -> Bool {
        let buddies = try await loadBuddies(for: characterID, from: database)
        return buddies.contains { $0.buddyID == buddyID }
    }
    
    /// Update buddy pending status
    public func updateBuddyPending(buddyID: Character.Index, for characterID: Character.ID, pending: Bool, in database: some ModelStorage) async throws -> Bool {
        var buddies = try await loadBuddies(for: characterID, from: database)
        
        guard let index = buddies.firstIndex(where: { $0.buddyID == buddyID }) else {
            return false
        }
        
        var updatedBuddy = buddies[index]
        updatedBuddy.pending = pending
        
        // Save to database
        try await database.insert(updatedBuddy)
        
        // Update cache
        buddies[index] = updatedBuddy
        cache[characterID] = buddies
        
        return true
    }
    
    /// Convert Buddy entities to notification format
    public func buddyListNotification(for characterID: Character.ID, in database: some ModelStorage) async throws -> [BuddyListNotification.Buddy] {
        let buddies = try await loadBuddies(for: characterID, from: database)
        return buddies.compactMap { buddy in
            // Only include non-pending buddies in the notification
            guard !buddy.pending else { return nil }
            // Note: We'd need to look up the buddy's name and online status from their character
            // For now, return a basic entry
            return BuddyListNotification.Buddy(
                id: buddy.buddyID,
                name: CharacterName(rawValue: "")!, // Would need to fetch from DB
                value0: 0,
                channel: -1 // Offline by default
            )
        }
    }
    
    // MARK: - Pending Request Operations (In-Memory Only)
    
    /// Add a pending buddy request (in-memory only, for active sessions)
    /// - Parameters:
    ///   - fromID: The character ID sending the request
    ///   - fromName: The name of the character sending the request
    ///   - toID: The character ID receiving the request
    /// - Returns: True if the request was added, false if already exists
    public func addPendingRequest(from fromID: Character.Index, fromName: CharacterName, to toID: Character.ID) -> Bool {
        var pending = pendingRequests[toID] ?? []
        
        // Check if request already exists
        guard !pending.contains(where: { $0.fromCharacterID == fromID }) else {
            return false
        }
        
        let request = PendingBuddyRequest(fromCharacterID: fromID, fromCharacterName: fromName)
        pending.append(request)
        pendingRequests[toID] = pending
        return true
    }
    
    /// Get all pending requests for a character
    public func getPendingRequests(for characterID: Character.ID) -> [PendingBuddyRequest] {
        pendingRequests[characterID] ?? []
    }
    
    /// Get the next pending request for a character (FIFO)
    public func nextPendingRequest(for characterID: Character.ID) -> PendingBuddyRequest? {
        pendingRequests[characterID]?.first
    }
    
    /// Remove a pending request
    public func removePendingRequest(from fromID: Character.Index, to toID: Character.ID) -> Bool {
        var pending = pendingRequests[toID] ?? []
        let originalCount = pending.count
        pending.removeAll { $0.fromCharacterID == fromID }
        guard pending.count != originalCount else {
            return false
        }
        if pending.isEmpty {
            pendingRequests.removeValue(forKey: toID)
        } else {
            pendingRequests[toID] = pending
        }
        return true
    }
    
    /// Poll (remove and return) the next pending request
    public func pollPendingRequest(for characterID: Character.ID) -> PendingBuddyRequest? {
        var pending = pendingRequests[characterID] ?? []
        guard let request = pending.first else {
            return nil
        }
        pending.removeFirst()
        if pending.isEmpty {
            pendingRequests.removeValue(forKey: characterID)
        } else {
            pendingRequests[characterID] = pending
        }
        return request
    }
    
    /// Check if there's a pending request from a specific character
    public func hasPendingRequest(from fromID: Character.Index, to toID: Character.ID) -> Bool {
        pendingRequests[toID]?.contains(where: { $0.fromCharacterID == fromID }) ?? false
    }
    
    // MARK: - Cache Management
    
    /// Clear the cache for a character (call when character logs out)
    public func clearCache(for characterID: Character.ID) {
        cache.removeValue(forKey: characterID)
        pendingRequests.removeValue(forKey: characterID)
    }
}

// MARK: - Pending Buddy Request

/// Represents a pending buddy request waiting for acceptance (in-memory only)
public struct PendingBuddyRequest: Codable, Equatable, Hashable, Sendable {
    
    /// The character ID of the player who sent the request
    public let fromCharacterID: Character.Index
    
    /// The name of the player who sent the request
    public let fromCharacterName: CharacterName
    
    /// When the request was created
    public let createdAt: Date
    
    public init(fromCharacterID: Character.Index, fromCharacterName: CharacterName, createdAt: Date = Date()) {
        self.fromCharacterID = fromCharacterID
        self.fromCharacterName = fromCharacterName
        self.createdAt = createdAt
    }
}