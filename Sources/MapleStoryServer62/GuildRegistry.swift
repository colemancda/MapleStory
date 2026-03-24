//
//  GuildRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry for managing guilds
public actor GuildRegistry {

    public static let shared = GuildRegistry()

    private var guilds: [GuildID: Guild] = [:]

    /// Next guild ID
    private var nextGuildID: GuildID = 1000

    private init() {}

    // MARK: - Guild Management

    /// Create a new guild
    public func createGuild(
        name: String,
        leaderID: Character.ID,
        leaderName: CharacterName
    ) -> Guild {
        let guildID = nextGuildID
        nextGuildID += 1

        let leader = GuildMember(
            characterID: leaderID,
            characterName: leaderName,
            rank: .master,
            online: true
        )

        let guild = Guild(
            id: guildID,
            name: name,
            leaderID: leaderID,
            members: [leaderID: leader],
            capacity: 30,
            points: 0
        )

        guilds[guildID] = guild
        return guild
    }

    /// Get guild by ID
    public func guild(_ guildID: GuildID) -> Guild? {
        return guilds[guildID]
    }

    /// Get guild for a character
    public func guild(for characterID: Character.ID) -> Guild? {
        for guild in guilds.values {
            if guild.members[characterID] != nil {
                return guild
            }
        }
        return nil
    }

    /// Add member to guild
    public func addMember(
        _ characterID: Character.ID,
        name: CharacterName,
        to guildID: GuildID
    ) -> Bool {
        guard var guild = guilds[guildID] else { return false }
        guard guild.memberCount < guild.capacity else { return false }

        let member = GuildMember(
            characterID: characterID,
            characterName: name,
            rank: .member,
            online: true
        )

        guild.members[characterID] = member
        guilds[guildID] = guild
        return true
    }

    /// Remove member from guild
    @discardableResult
    public func removeMember(_ characterID: Character.ID, from guildID: GuildID) -> Bool {
        guard var guild = guilds[guildID] else { return false }
        guard guild.members[characterID] != nil else { return false }

        guild.members.removeValue(forKey: characterID)

        // If leader left, disband guild
        if guild.leaderID == characterID {
            guilds.removeValue(forKey: guildID)
        } else {
            guilds[guildID] = guild
        }

        return true
    }

    /// Update member rank
    public func updateMemberRank(_ characterID: Character.ID, rank: GuildRank, guildID: GuildID) -> Bool {
        guard var guild = guilds[guildID] else { return false }
        guard var member = guild.members[characterID] else { return false }

        member.rank = rank
        guild.members[characterID] = member
        guilds[guildID] = guild
        return true
    }

    /// Update member online status
    public func updateMemberStatus(_ characterID: Character.ID, online: Bool) {
        guard let guildID = guild(for: characterID)?.id else { return }
        guard var guild = guilds[guildID],
              var member = guild.members[characterID] else { return }

        member.online = online
        guild.members[characterID] = member
        guilds[guildID] = guild
    }

    /// Disband guild
    public func disbandGuild(_ guildID: GuildID) {
        guilds.removeValue(forKey: guildID)
    }

    /// Load guilds from database
    public func loadGuilds(from database: some ModelStorage) async throws {
        // TODO: Implement database loading
    }

    /// Save guilds to database
    public func saveGuilds(to database: some ModelStorage) async throws {
        // TODO: Implement database saving
    }
}
