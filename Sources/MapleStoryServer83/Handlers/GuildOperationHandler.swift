//
//  GuildOperationHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct GuildOperationHandler: PacketHandler {

    public typealias Packet = MapleStory83.GuildOperationRequest

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
                return
            }
            try await GuildRegistry.shared.removeMember(character.id, from: guild.id, in: connection.database)
            try await connection.send(GuildOperationNotification(operation: .leave, guildID: nil))

        case 0x08: // Expel member
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database),
                  let targetCharacterID = packet.characterID else {
                return
            }
            let guildMembers = try await GuildRegistry.shared.loadGuildMembers(guild.id, from: connection.database)
            guard let actorMember = guildMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            _ = try await GuildRegistry.shared.removeMember(targetCharacterID, from: guild.id, in: connection.database)
            try await connection.send(GuildOperationNotification(operation: .expel, guildID: guild.guildID))

        case 0x0E: // Change rank
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database),
                  let targetCharacterID = packet.characterID,
                  let rankValue = packet.rank,
                  let newRank = GuildRank(rawValue: rankValue) else {
                return
            }
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
            try await connection.send(GuildOperationNotification(operation: .rank, guildID: guild.guildID))

        case 0x10: // Disband guild
            guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database) else {
                return
            }
            guard guild.leaderID == character.id else { return }
            try await GuildRegistry.shared.disbandGuild(guild.id, in: connection.database)
            try await connection.send(GuildOperationNotification(operation: .disband, guildID: nil))

        default:
            return
        }
    }
}
