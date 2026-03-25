//
//  GuildRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62

import MapleStoryServer

/// Registry for managing guilds with database persistence.
///
/// This actor manages guild state with persistence to the database.
/// It maintains an in-memory cache for performance.
public actor GuildRegistry {

    public static let shared = GuildRegistry()

    private init() { }
    
    // MARK: - Properties
    
    /// In-memory guild cache indexed by guild UUID
    private var guilds: [GuildEntity.ID: GuildEntity] = [:]
    
    /// In-memory guild member cache indexed by character UUID
    private var guildMembers: [Character.ID: GuildMemberEntity] = [:]
    
    /// In-memory pending guild invitations indexed by character UUID
    private var pendingInvites: [Character.ID: PendingGuildInvite] = [:]
    
    /// Next guild ID for generating new guilds
    private var nextGuildID: UInt32 = 1000
    
    // MARK: - Guild Management
    
    /// Load a guild from database
    public func loadGuild(_ guildID: GuildEntity.ID, from database: any ModelStorage) async throws -> GuildEntity? {
        // Check cache first
        if let cached = guilds[guildID] {
            return cached
        }
        
        // Load from database
        let predicate = FetchRequest.Predicate.attribute(.init(name: "id", value: guildID))
        guard let guild = try await database.fetch(GuildEntity.self, predicate: predicate, fetchLimit: 1).first else {
            return nil
        }
        
        // Cache the result
        guilds[guildID] = guild
        
        return guild
    }
    
    /// Load all members for a guild from database
    public func loadGuildMembers(_ guildID: GuildEntity.ID, from database: any ModelStorage) async throws -> [GuildMemberEntity] {
        // Check cache first
        var members: [GuildMemberEntity] = []
        for cachedMember in guildMembers.values where cachedMember.guild == guildID {
            members.append(cachedMember)
        }
        if members.isEmpty {
            // Load from database
            let predicate = FetchRequest.Predicate.relationship(.init(name: "guild", value: guildID))
            members = try await database.fetch(GuildMemberEntity.self, predicate: predicate)
        }
        
        return members
    }
    
    /// Get guild for a character
    public func guild(for characterID: Character.ID, in database: any ModelStorage) async throws -> GuildEntity? {
        // Check if character is in a guild (cached)
        if let member = guildMembers[characterID] {
            return try await loadGuild(member.guild, from: database)
        }
        
        // Not in cache, load from database
        let predicate = FetchRequest.Predicate.relationship(.init(name: "character", value: characterID))
        guard let member = try await database.fetch(GuildMemberEntity.self, predicate: predicate, fetchLimit: 1).first else {
            return nil
        }
        
        // Cache the member
        guildMembers[characterID] = member
        
        return try await loadGuild(member.guild, from: database)
    }
    
    /// Create a new guild
    public func createGuild(
        name: String,
        leaderID: Character.ID,
        leaderName: CharacterName,
        in database: any ModelStorage
    ) async throws -> GuildEntity {
        let guildID = GuildEntity.ID()
        nextGuildID += 1
        
        let guild = GuildEntity(
            id: guildID,
            name: name,
            leaderID: leaderID,
            capacity: 30,
            points: 0,
            logoBackground: 0,
            logoBackgroundColor: 0,
            logo: 0,
            logoColor: 0,
            notice: nil
        )
        
        let member = GuildMemberEntity(
            id: UUID(),
            guild: guildID,
            characterID: leaderID,
            characterName: leaderName,
            rank: .master,
            online: true
        )
        
        // Save to database
        try await database.insert(guild)
        try await database.insert(member)
        
        // Update cache
        guilds[guildID] = guild
        guildMembers[leaderID] = member
        
        return guild
    }
    
    /// Add member to guild
    public func addMember(
        _ characterID: Character.ID,
        name: CharacterName,
        to guildID: GuildEntity.ID,
        in database: any ModelStorage
    ) async throws -> Bool {
        guard var guild = try await loadGuild(guildID, from: database) else { return false }
        
        // Count members from database
        let members = try await loadGuildMembers(guildID, from: database)
        guard members.count >= guild.capacity else { return false }
        
        let member = GuildMemberEntity(
            id: UUID(),
            guild: guildID,
            characterID: characterID,
            characterName: name,
            rank: .member,
            online: true
        )
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        guildMembers[characterID] = member
        
        return true
    }
    
    /// Remove member from guild
    @discardableResult
    public func removeMember(_ characterID: Character.ID, from guildID: GuildEntity.ID, in database: any ModelStorage) async throws -> Bool {
        guard let member = guildMembers[characterID] else { return false }
        guard member.guild == guildID else { return false }
        
        // Delete from database
        try await database.delete(GuildMemberEntity.self, for: member.id)
        
        // Remove from cache
        guildMembers.removeValue(forKey: characterID)
        
        // Check if guild should be disbanded (leader left)
        if let guild = guilds[guildID], guild.leaderID == characterID {
            // Disband guild
            try await disbandGuild(guildID, in: database)
        }
        
        return true
    }
    
    /// Update member rank
    public func updateMemberRank(_ characterID: Character.ID, rank: GuildRank, in database: any ModelStorage) async throws -> Bool {
        guard var member = guildMembers[characterID] else { return false }
        
        member.rank = rank
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        guildMembers[characterID] = member
        
        return true
    }
    
    /// Update member online status
    public func updateMemberStatus(_ characterID: Character.ID, online: Bool, in database: any ModelStorage) async throws {
        guard var member = guildMembers[characterID] else { return }
        
        member.online = online
        
        // Save to database
        try await database.insert(member)
        
        // Update cache
        guildMembers[characterID] = member
    }
    
    /// Disband guild
    public func disbandGuild(_ guildID: GuildEntity.ID, in database: any ModelStorage) async throws {
        // Delete all members from database
        let members = try await loadGuildMembers(guildID, from: database)
        for member in members {
            try await database.delete(GuildMemberEntity.self, for: member.id)
            guildMembers.removeValue(forKey: member.characterID)
        }
        
        // Delete guild from database
        try await database.delete(GuildEntity.self, for: guildID)
        
        // Remove from cache
        guilds.removeValue(forKey: guildID)
    }
    
    /// Change guild leader
    @discardableResult
    public func changeLeader(_ guildID: GuildEntity.ID, to characterID: Character.ID, in database: any ModelStorage) async throws -> Bool {
        guard var guild = guilds[guildID] else { return false }
        guard guildMembers[characterID] != nil else { return false }
        guard guildMembers[characterID]?.guild == guildID else { return false }
        
        var updatedGuild = guild
        updatedGuild.leaderID = characterID
        
        // Save to database
        try await database.insert(updatedGuild)
        
        // Update cache
        guilds[guildID] = updatedGuild
        
        return true
    }
    
    /// Update guild capacity
    public func updateCapacity(_ guildID: GuildEntity.ID, capacity: Int, in database: any ModelStorage) async throws -> Bool {
        guard var guild = guilds[guildID] else { return false }
        
        guild.capacity = capacity
        
        // Save to database
        try await database.insert(guild)
        
        // Update cache
        guilds[guildID] = guild
        
        return true
    }
    
    /// Update guild points
    public func updatePoints(_ guildID: GuildEntity.ID, points: UInt32, in database: any ModelStorage) async throws -> Bool {
        guard var guild = guilds[guildID] else { return false }
        
        guild.points = points
        
        // Save to database
        try await database.insert(guild)
        
        // Update cache
        guilds[guildID] = guild
        
        return true
    }
    
    /// Update guild logo
    public func updateLogo(
        _ guildID: GuildEntity.ID,
        logoBackground: UInt8,
        logoBackgroundColor: UInt8,
        logo: UInt8,
        logoColor: UInt8,
        in database: any ModelStorage
    ) async throws -> Bool {
        guard var guild = guilds[guildID] else { return false }
        
        guild.logoBackground = logoBackground
        guild.logoBackgroundColor = logoBackgroundColor
        guild.logo = logo
        guild.logoColor = logoColor
        
        // Save to database
        try await database.insert(guild)
        
        // Update cache
        guilds[guildID] = guild
        
        return true
    }
    
    /// Update guild notice
    public func updateNotice(_ guildID: GuildEntity.ID, notice: String?, in database: any ModelStorage) async throws -> Bool {
        guard var guild = guilds[guildID] else { return false }
        
        guild.notice = notice
        
        // Save to database
        try await database.insert(guild)
        
        // Update cache
        guilds[guildID] = guild
        
        return true
    }
    
    /// Clear cache for a character (call when character logs out)
    public func clearCache(for characterID: Character.ID) {
        guildMembers.removeValue(forKey: characterID)
    }
    
    // MARK: - Pending Invites (In-Memory Only)
    
    /// Add a pending guild invite
    public func addPendingInvite(_ invite: PendingGuildInvite) -> Bool {
        guard pendingInvites[invite.characterID] == nil else { return false }
        pendingInvites[invite.characterID] = invite
        return true
    }
    
    /// Get pending invite for a character
    public func getPendingInvite(for characterID: Character.ID) -> PendingGuildInvite? {
        return pendingInvites[characterID]
    }
    
    /// Remove pending invite
    public func removePendingInvite(for characterID: Character.ID) -> Bool {
        guard pendingInvites[characterID] != nil else { return false }
        pendingInvites.removeValue(forKey: characterID)
        return true
    }
}

// MARK: - Pending Guild Invite (In-Memory Only)

/// Represents a pending guild invitation (in-memory only)
public struct PendingGuildInvite: Codable, Equatable, Hashable, Sendable {
    
    /// The guild ID
    public let guildID: GuildEntity.ID
    
    /// The character who was invited
    public let characterID: Character.ID
    
    /// The character's name
    public let characterName: CharacterName
    
    /// The character who sent the invitation
    public let fromCharacterID: Character.ID
    
    /// The character who sent the invitation (name)
    public let fromCharacterName: CharacterName
    
    /// When the invitation was created
    public let createdAt: Date
    
    public init(
        guildID: GuildEntity.ID,
        characterID: Character.ID,
        characterName: CharacterName,
        fromCharacterID: Character.ID,
        fromCharacterName: CharacterName,
        createdAt: Date = Date()
    ) {
        self.guildID = guildID
        self.characterID = characterID
        self.characterName = characterName
        self.fromCharacterID = fromCharacterID
        self.fromCharacterName = fromCharacterName
        self.createdAt = createdAt
    }
}