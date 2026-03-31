//
//  GuildOperationHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer
import MapleStoryServer62

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
                try await connection.send(ServerMessageNotification.notice(message: "You cannot create a new Guild while in one."))
                return
            }
            guard let guildName = packet.guildName, isGuildNameAcceptable(guildName) else {
                try await connection.send(ServerMessageNotification.notice(message: "The Guild name you have chosen is not accepted."))
                return
            }
            let guild = try await connection.createGuild(
                name: guildName,
                leaderID: character.id,
                leaderName: character.name
            )
            try await connection.send(GuildOperationNotification(operation: .create, guildID: guild.guildID))

        case 0x05: // Invite by name
            guard let guild = try await connection.guild(for: character.id) else { return }
            let guildMembers = try await connection.guildMembers(guild.id)
            guard let actorMember = guildMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            guard let targetNameString = packet.characterName, targetNameString.isEmpty == false,
                  let targetName = CharacterName(rawValue: targetNameString) else { return }
            let predicates: [Character.Predicate] = [.name(targetName), .world(character.world)]
            let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
            guard let target = try await connection.database.fetch(
                Character.self,
                predicate: predicate,
                fetchLimit: 1
            ).first else {
                try await connection.send(ServerMessageNotification.notice(message: "That character does not exist."))
                return
            }
            guard try await connection.guild(for: target.id) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "\(targetName.rawValue) is already in a guild."))
                return
            }
            let invite = PendingGuildInvite(
                guildID: guild.id,
                characterID: target.id,
                characterName: target.name,
                fromCharacterID: character.id,
                fromCharacterName: character.name
            )
            guard await connection.addPendingGuildInvite(invite) else {
                try await connection.send(ServerMessageNotification.notice(message: "A guild invitation has already been sent to \(targetName.rawValue)."))
                return
            }
            try await connection.send(ServerMessageNotification.notice(message: "Guild invite sent to \(targetName.rawValue)."))

        case 0x06: // Accept guild invite
            guard try await connection.guild(for: character.id) == nil else { return }
            guard let invite = await connection.pendingGuildInvite(for: character.id) else { return }
            let joined = try await connection.addGuildMember(character.id, name: character.name, to: invite.guildID)
            await connection.removePendingGuildInvite(for: character.id)
            guard joined else {
                try await connection.send(ServerMessageNotification.notice(message: "The guild you are trying to join is already full."))
                return
            }
            // Load the guild to get its numeric ID for the response
            let joinedGuild = try await connection.guild(for: character.id)
            try await connection.send(GuildOperationNotification(operation: .create, guildID: joinedGuild?.guildID))

        case 0x07: // Leave guild
            guard let guild = try await connection.guild(for: character.id) else { return }
            // Validate that the packet identifies the acting character
            if let packetCharacterID = packet.characterID, packetCharacterID != character.id { return }
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
                  let rankValue = packet.rank else {
                return
            }
            // Rank must be 2–5 (cannot promote to master via this path)
            guard rankValue >= 2, rankValue <= 5,
                  let newRank = GuildRank(rawValue: rankValue) else {
                return
            }
            let rankMembers = try await connection.guildMembers(guild.id)
            guard let actorMember = rankMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            // Only master can assign jr-master (rank 2)
            if rankValue <= 2 && actorMember.rank != GuildRank.master { return }
            guard try await connection.updateGuildMemberRank(targetCharacterID, rank: newRank) else { return }
            try await connection.send(GuildOperationNotification(operation: .rank, guildID: guild.guildID))

        case 0x10: // Change guild notice
            guard let guild = try await connection.guild(for: character.id) else { return }
            let guildMembers = try await connection.guildMembers(guild.id)
            guard let actorMember = guildMembers.first(where: { $0.characterID == character.id }),
                  actorMember.rank.rawValue <= 2 else {
                return
            }
            let notice = packet.notice ?? ""
            guard notice.count <= 100 else { return }
            try await connection.updateGuildNotice(guild.id, notice: notice.isEmpty ? nil : notice)

        default:
            return
        }
    }

    // MARK: - Private

    private func isGuildNameAcceptable(_ name: String) -> Bool {
        guard name.count >= 3, name.count <= 12 else { return false }
        return name.allSatisfy { $0.isLetter }
    }
}
