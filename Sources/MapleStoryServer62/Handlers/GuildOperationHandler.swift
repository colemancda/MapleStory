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
            // For now, stub - would need guild name from packet
            return

        case 0x05: // Leave guild
            guard let guild = await GuildRegistry.shared.guild(for: character.id) else {
                return // Not in a guild
            }

            await GuildRegistry.shared.removeMember(character.id, from: guild.id)

            try await connection.send(GuildOperationNotification(
                operation: .leave,
                guildID: nil
            ))

        case 0x0C: // Expel member
            return

        case 0x0E: // Change rank
            return

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
