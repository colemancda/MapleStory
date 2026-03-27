//
//  GuildOperationHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles guild management operations (create, leave, expel, rank change, disband).
///
/// # Guild Operations
///
/// | Code | Operation | Description |
/// |------|-----------|-------------|
/// | 0x02 | Create | Create a new guild |
/// | 0x07 | Leave | Leave current guild |
/// | 0x08 | Expel | Remove a member (master/jr. master only) |
/// | 0x0E | Rank | Change a member's rank (master/jr. master only) |
/// | 0x10 | Disband | Disband the guild (master only) |
///
/// # Guild Ranks
///
/// - **1 - Master**: Guild leader, full permissions
/// - **2 - Jr. Master**: Second in command, can manage members
/// - **3-5 - Members**: Regular members with no management rights
///
/// # Response
///
/// Sends `GuildOperationNotification` indicating the result of the operation.
public struct GuildOperationHandler: PacketHandler {

    public typealias Packet = MapleStory62.GuildOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet.type {
        case 0x02: // Create guild
            guard try await GuildRegistry.shared.guild(for: character.id, in: connection.database) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a guild."))
                return
            }
            guard let guildName = packet.guildName, guildName.isEmpty == false else {
                return
            }
            let guild = try await GuildRegistry.shared.createGuild(
                name: guildName,
                leaderID: character.id,
                leaderName: character.name,
                in: connection.database
            )
            try await connection.send(GuildOperationNotification(
                operation: .create,
                guildID: guild.guildID
            ))

        case 0x07: // Leave guild
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database) else {
                return // Not in a guild
            }

            try await GuildRegistry.shared.removeMember(character.id, from: guild.id, in: connection.database)

            try await connection.send(GuildOperationNotification(
                operation: .leave,
                guildID: nil
            ))

        case 0x08: // Expel member
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database),
                  let targetCharacterID = packet.characterID else {
                return
            }
            // Allow guild master / jr master to expel.
            let guildMembers = try await GuildRegistry.shared.loadGuildMembers(guild.id, from: connection.database)
            guard let actorMember = guildMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            _ = try await GuildRegistry.shared.removeMember(targetCharacterID, from: guild.id, in: connection.database)
            try await connection.send(GuildOperationNotification(
                operation: .expel,
                guildID: guild.guildID
            ))

        case 0x0E: // Change rank
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database),
                  let targetCharacterID = packet.characterID,
                  let rankValue = packet.rank,
                  let newRank = GuildRank(rawValue: rankValue) else {
                return
            }
            // Guild master/jr master can manage ranks, but only master can assign master/jr master.
            let rankMembers = try await GuildRegistry.shared.loadGuildMembers(guild.id, from: connection.database)
            guard let actorMember = rankMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            if newRank.rawValue <= 2 && actorMember.rank != GuildRank.master {
                return
            }
            guard try await GuildRegistry.shared.updateMemberRank(targetCharacterID, rank: newRank, in: connection.database) else {
                return
            }
            try await connection.send(GuildOperationNotification(
                operation: .rank,
                guildID: guild.guildID
            ))

        case 0x10: // Disband guild
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database) else {
                return // Not in a guild
            }

            guard guild.leaderID == character.id else {
                return // Not guild master
            }

            try await GuildRegistry.shared.disbandGuild(guild.id, in: connection.database)

            try await connection.send(GuildOperationNotification(
                operation: .disband,
                guildID: nil
            ))

        default:
            return
        }
    }
}
