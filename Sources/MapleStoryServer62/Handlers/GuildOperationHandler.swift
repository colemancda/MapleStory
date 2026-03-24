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
            guard await GuildRegistry.shared.guild(for: character.id) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a guild."))
                return
            }
            guard let guildName = packet.guildName, guildName.isEmpty == false else {
                return
            }
            let guild = await GuildRegistry.shared.createGuild(
                name: guildName,
                leaderID: character.id,
                leaderName: character.name
            )
            try await connection.send(GuildOperationNotification(
                operation: .create,
                guildID: guild.id
            ))

        case 0x07: // Leave guild
            guard let guild = await GuildRegistry.shared.guild(for: character.id) else {
                return // Not in a guild
            }

            await GuildRegistry.shared.removeMember(character.id, from: guild.id)

            try await connection.send(GuildOperationNotification(
                operation: .leave,
                guildID: nil
            ))

        case 0x08: // Expel member
            guard let guild = await GuildRegistry.shared.guild(for: character.id),
                  let targetCharacterID = packet.characterID else {
                return
            }
            // Allow guild master / jr master to expel.
            guard let actorMember = guild.members[character.id], actorMember.rank.rawValue <= 2 else {
                return
            }
            _ = await GuildRegistry.shared.removeMember(targetCharacterID, from: guild.id)
            try await connection.send(GuildOperationNotification(
                operation: .expel,
                guildID: guild.id
            ))

        case 0x0E: // Change rank
            guard let guild = await GuildRegistry.shared.guild(for: character.id),
                  let targetCharacterID = packet.characterID,
                  let rankValue = packet.rank,
                  let newRank = GuildRank(rawValue: rankValue) else {
                return
            }
            // Guild master/jr master can manage ranks, but only master can assign master/jr master.
            guard let actorMember = guild.members[character.id], actorMember.rank.rawValue <= 2 else {
                return
            }
            if newRank.rawValue <= 2 && actorMember.rank != .master {
                return
            }
            guard await GuildRegistry.shared.updateMemberRank(targetCharacterID, rank: newRank, guildID: guild.id) else {
                return
            }
            try await connection.send(GuildOperationNotification(
                operation: .rank,
                guildID: guild.id
            ))

        case 0x10: // Disband guild
            guard let guild = await GuildRegistry.shared.guild(for: character.id) else {
                return // Not in a guild
            }

            guard guild.leaderID == character.id else {
                return // Not guild master
            }

            await GuildRegistry.shared.disbandGuild(guild.id)

            try await connection.send(GuildOperationNotification(
                operation: .disband,
                guildID: nil
            ))

        default:
            return
        }
    }
}
