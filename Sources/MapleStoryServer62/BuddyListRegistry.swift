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

/// Registry for managing buddy lists and pending buddy requests.
///
/// This actor manages in-memory buddy list state including:
/// - Current buddy lists for each character
/// - Pending buddy requests waiting for acceptance
/// - Capacity checking for buddy lists
public actor BuddyListRegistry {

    public static let shared = BuddyListRegistry()

    /// In-memory buddy lists indexed by character ID
    private var lists: [Character.ID: [BuddyListNotification.Buddy]] = [:]
    
    /// Pending buddy requests indexed by the character who will receive the request
    private var pendingRequests: [Character.ID: [PendingBuddyRequest]] = [:]

    private init() { }

    // MARK: - Buddy List Operations
    
    public func list(for characterID: Character.ID) -> [BuddyListNotification.Buddy] {
        lists[characterID] ?? []
    }
    
    /// Returns the count of non-pending (confirmed) buddies
    public func buddyCount(for characterID: Character.ID) -> Int {
        list(for: characterID).count
    }
    
    /// Checks if the buddy list is at or above capacity
    public func isFull(_ characterID: Character.ID, capacity: UInt8) -> Bool {
        buddyCount(for: characterID) >= Int(capacity)
    }

    public func add(_ buddy: BuddyListNotification.Buddy, to characterID: Character.ID) -> Bool {
        var current = lists[characterID] ?? []
        guard current.contains(where: { $0.id == buddy.id }) == false else {
            return false
        }
        current.append(buddy)
        current.sort { $0.name.rawValue < $1.name.rawValue }
        lists[characterID] = current
        return true
    }

    public func remove(buddyID: UInt32, from characterID: Character.ID) -> Bool {
        var current = lists[characterID] ?? []
        let originalCount = current.count
        current.removeAll { $0.id == buddyID }
        guard current.count != originalCount else {
            return false
        }
        lists[characterID] = current
        return true
    }
    
    /// Check if a buddy is already in the list
    public func contains(buddyID: UInt32, in characterID: Character.ID) -> Bool {
        lists[characterID]?.contains(where: { $0.id == buddyID }) ?? false
    }
    
    // MARK: - Pending Request Operations
    
    /// Add a pending buddy request
    /// - Parameters:
    ///   - fromID: The character ID sending the request
    ///   - fromName: The name of the character sending the request
    ///   - toID: The character ID receiving the request
    /// - Returns: True if the request was added, false if already exists
    public func addPendingRequest(from fromID: UInt32, fromName: CharacterName, to toID: Character.ID) -> Bool {
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
    public func removePendingRequest(from fromID: UInt32, to toID: Character.ID) -> Bool {
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
    public func hasPendingRequest(from fromID: UInt32, to toID: Character.ID) -> Bool {
        pendingRequests[toID]?.contains(where: { $0.fromCharacterID == fromID }) ?? false
    }
}

// MARK: - Pending Buddy Request

/// Represents a pending buddy request waiting for acceptance
public struct PendingBuddyRequest: Codable, Equatable, Hashable, Sendable {
    
    /// The character ID of the player who sent the request
    public let fromCharacterID: UInt32
    
    /// The name of the player who sent the request
    public let fromCharacterName: CharacterName
    
    /// When the request was created
    public let createdAt: Date
    
    public init(fromCharacterID: UInt32, fromCharacterName: CharacterName, createdAt: Date = Date()) {
        self.fromCharacterID = fromCharacterID
        self.fromCharacterName = fromCharacterName
        self.createdAt = createdAt
    }
}