//
//  PartyRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62

/// Registry for managing parties with database persistence.
///
/// This actor manages party state with persistence to the database.
/// It maintains an in-memory cache for performance.
public actor PartyRegistry {

    public static let shared = PartyRegistry()

    private init() { }
    
    // MARK: - Properties
    
    /// In-memory party cache indexed by party UUID
    private var parties: [PartyEntity.ID: PartyEntity] = [:]
    
    /// In-memory party member cache indexed by character UUID
    private var partyMembers: [Character.ID: PartyMemberEntity] = [:]
    
    /// In-memory pending party invitations indexed by character UUID
    private var pendingInvites: [Character.ID: PendingPartyInvite] = [:]
    
    /// Next party ID for generating new parties
    private var nextPartyID: UInt32 = 1000
    
    // MARK: - Party Management
    
    /// Load a party from database
    public func loadParty(_ partyID: PartyEntity.ID, from database: any ModelStorage) async throws -> PartyEntity? {
        // Check cache first
        if let cached = parties[partyID] {
            return cached
        }
        
        // Load from database
        let predicate = FetchRequest.Predicate.attribute(.init(name: "id", value: partyID))
        guard let party = try await database.fetch(PartyEntity.self, predicate: predicate, fetchLimit: 1).first else {
            return nil
        }
        
        // Cache the result
        parties[partyID] = party
        
        return party
    }
    
    /// Load all members for a party from database
    public func loadPartyMembers(_ partyID: PartyEntity.ID, from database: any ModelStorage) async throws -> [PartyMemberEntity] {
        // Check cache first
        var members: [PartyMemberEntity] = []
        for cachedMember in partyMembers.values where cachedMember.party == partyID {
            members.append(cachedMember)
        }
        if members.isEmpty {
            // Load from database
            let predicate = FetchRequest.Predicate.relationship(.init(name: "party", value: partyID))
            members = try await database.fetch(PartyMemberEntity.self, predicate: predicate)
        }
        
        return members
    }
    
    /// Get party for a character
    public func party(for characterID: Character.ID, in database: any ModelStorage) async throws -> PartyEntity? {
        // Check if character is in a party (cached)
        if let member = partyMembers[characterID] {
            return try await loadParty(member.party, from: database)
        }
        
        // Not in cache, load from database
        let predicate = FetchRequest.Predicate.relationship(.init(name: "character", value: characterID))
        guard let member = try await database.fetch(PartyMemberEntity.self, predicate: predicate, fetchLimit: 1).first else {
            return nil
        }
        
        // Cache the member
        partyMembers[characterID] = member
        
        return try await loadParty(member.party, from: database)
    }
    
    /// Create a new party
    public func createParty(
        leaderID: Character.ID,
        leaderName: CharacterName,
        leaderJob: Job,
        leaderLevel: UInt16,
        channel: UInt8,
        map: Map.ID,
        in database: any ModelStorage
    ) async throws -> PartyEntity {
        let partyID = PartyEntity.ID()
        nextPartyID += 1
        
        let party = PartyEntity(
            id: partyID,
            leaderID: leaderID,
            createdAt: Date()
        )
        
        let member = PartyMemberEntity(
            id: UUID(),
            party: partyID,
            characterID: leaderID,
            characterName: leaderName,
            job: leaderJob,
            level: leaderLevel,
            channel: channel,
            map: map,
            status: .online
        )
        
        // Save to database
        try await database.insert(party)
        try await database.insert(member)
        
        // Update cache
        parties[partyID] = party
        partyMembers[leaderID] = member
        
        return party
    }
    
    /// Add member to party
    public func addMember(
        _ characterID: Character.ID,
        name: CharacterName,
        job: Job,
        level: UInt16,
        channel: UInt8,
        map: Map.ID,
        to partyID: PartyEntity.ID,
        in database: any ModelStorage
    ) async throws -> Bool {
        guard var party = try await loadParty(partyID, from: database) else { return false }
        guard party.members.count < 6 else { return false }
        
        let member = PartyMemberEntity(
            id: UUID(),
            party: partyID,
            characterID: characterID,
            characterName: name,
            job: job,
            level: level,
            channel: channel,
            map: map,
            status: .online
        )
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        partyMembers[characterID] = member
        
        return true
    }
    
    /// Remove member from party
    @discardableResult
    public func removeMember(_ characterID: Character.ID, from partyID: PartyEntity.ID, in database: any ModelStorage) async throws -> Bool {
        guard let member = partyMembers[characterID] else { return false }
        guard member.party == partyID else { return false }
        
        // Delete from database
        try await database.delete(PartyMemberEntity.self, for: member.id)
        
        // Remove from cache
        partyMembers.removeValue(forKey: characterID)
        
        // Check if party should be disbanded
        let members = try await loadPartyMembers(partyID, from: database)
        if members.isEmpty {
            // Disband party
            try await database.delete(PartyEntity.self, for: partyID)
            parties.removeValue(forKey: partyID)
        } else if var party = parties[partyID], party.leaderID == characterID {
            // Transfer leadership to next member
            if let newLeader = members.first {
                var updatedParty = party
                updatedParty.leaderID = newLeader.characterID
                try await database.insert(updatedParty)
                parties[partyID] = updatedParty
            }
        }
        
        return true
    }
    
    /// Update member status (online/offline)
    public func updateMemberStatus(_ characterID: Character.ID, status: PartyMemberStatus, in database: any ModelStorage) async throws {
        guard var member = partyMembers[characterID] else { return }
        
        member.status = status
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        partyMembers[characterID] = member
    }
    
    /// Update member location
    public func updateMemberLocation(_ characterID: Character.ID, channel: UInt8, map: Map.ID, in database: any ModelStorage) async throws {
        guard var member = partyMembers[characterID] else { return }
        
        member.channel = channel
        member.map = map
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        partyMembers[characterID] = member
    }
    
    /// Disband party
    public func disbandParty(_ partyID: PartyEntity.ID, in database: any ModelStorage) async throws {
        // Delete all members from database
        let members = try await loadPartyMembers(partyID, from: database)
        for member in members {
            try await database.delete(PartyMemberEntity.self, for: member.id)
            partyMembers.removeValue(forKey: member.characterID)
        }
        
        // Delete party from database
        try await database.delete(PartyEntity.self, for: partyID)
        
        // Remove from cache
        parties.removeValue(forKey: partyID)
    }
    
    /// Transfer party leadership
    @discardableResult
    public func transferLeadership(_ partyID: PartyEntity.ID, to characterID: Character.ID, in database: any ModelStorage) async throws -> Bool {
        guard var party = parties[partyID] else { return false }
        guard partyMembers[characterID] != nil else { return false }
        guard partyMembers[characterID]?.party == partyID else { return false }
        
        var updatedParty = party
        updatedParty.leaderID = characterID
        
        // Save to database
        try await database.insert(updatedParty)
        
        // Update cache
        parties[partyID] = updatedParty
        
        return true
    }
    
    /// Clear cache for a character (call when character logs out)
    public func clearCache(for characterID: Character.ID) {
        partyMembers.removeValue(forKey: characterID)
    }
}

// MARK: - Pending Party Invite (In-Memory Only)

/// Represents a pending party invitation (in-memory only)
public struct PendingPartyInvite: Codable, Equatable, Hashable, Sendable {
    
    /// The party ID
    public let partyID: PartyEntity.ID
    
    /// The character who sent the invitation
    public let fromCharacterID: Character.ID
    
    /// The character who sent the invitation (name)
    public let fromCharacterName: CharacterName
    
    /// When the invitation was created
    public let createdAt: Date
    
    public init(
        partyID: PartyEntity.ID,
        fromCharacterID: Character.ID,
        fromCharacterName: CharacterName,
        createdAt: Date = Date()
    ) {
        self.partyID = partyID
        self.fromCharacterID = fromCharacterID
        self.fromCharacterName = fromCharacterName
        self.createdAt = createdAt
    }
}