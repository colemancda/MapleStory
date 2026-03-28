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
            guard try await connection.guild(for: character.id) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a guild."))
                return
            }
            guard let guildName = packet.guildName, guildName.isEmpty == false else { return }
            let guild = try await connection.createGuild(
                name: guildName,
                leaderID: character.id,
                leaderName: character.name
            )
            try await connection.send(GuildOperationNotification(operation: .create, guildID: guild.guildID))

        case 0x07: // Leave guild
            guard let guild = try await connection.guild(for: character.id) else { return }
            try await connection.removeGuildMember(character.id, from: guild.id)
            try await connection.send(GuildOperationNotification(operation: .leave, guildID: nil))

        case 0x08: // Expel member
            guard let guild = try await connection.guild(for: character.id),
                  let targetCharacterID = packet.characterID else {
                return
            }
            let guildMembers = try await connection.guildMembers(guild.id)
            guard let actorMember = guildMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            _ = try await connection.removeGuildMember(targetCharacterID, from: guild.id)
            try await connection.send(GuildOperationNotification(operation: .expel, guildID: guild.guildID))

        case 0x0E: // Change rank
            guard let guild = try await connection.guild(for: character.id),
                  let targetCharacterID = packet.characterID,
                  let rankValue = packet.rank,
                  let newRank = GuildRank(rawValue: rankValue) else {
                return
            }
            let rankMembers = try await connection.guildMembers(guild.id)
            guard let actorMember = rankMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            if newRank.rawValue <= 2 && actorMember.rank != GuildRank.master { return }
            guard try await connection.updateGuildMemberRank(targetCharacterID, rank: newRank) else { return }
            try await connection.send(GuildOperationNotification(operation: .rank, guildID: guild.guildID))

        case 0x10: // Disband guild
            guard let guild = try await connection.guild(for: character.id) else { return }
            guard guild.leaderID == character.id else { return }
            try await connection.disbandGuild(guild.id)
            try await connection.send(GuildOperationNotification(operation: .disband, guildID: nil))

        default:
            return
        }
    }
}
