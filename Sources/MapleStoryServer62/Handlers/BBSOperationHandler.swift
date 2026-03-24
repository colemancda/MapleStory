//
//  BBSOperationHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct BBSOperationHandler: PacketHandler {

    public typealias Packet = MapleStory62.BBSOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Character must be in a guild
        guard let guild = await GuildRegistry.shared.guild(for: character.id) else { return }
        let guildID = guild.id
        let characterID = character.index

        switch packet {
        case let .new(notice, title, body, icon):
            guard isValidIcon(icon) else { return }
            await BBSRegistry.shared.createThread(
                guildID: guildID,
                posterCharacterID: characterID,
                notice: notice,
                title: title,
                body: body,
                icon: icon
            )
            try await sendThreadList(guildID: guildID, start: 0, connection: connection)

        case let .edit(id, _, title, body, icon):
            guard isValidIcon(icon) else { return }
            let canEdit = await canModifyThread(localID: id, guildID: guildID, characterID: characterID, guild: guild)
            guard canEdit else { return }
            await BBSRegistry.shared.editThread(localID: id, guildID: guildID, title: title, body: body, icon: icon)
            try await sendThread(localID: id, guildID: guildID, connection: connection)

        case let .delete(id):
            let canDelete = await canModifyThread(localID: id, guildID: guildID, characterID: characterID, guild: guild)
            guard canDelete else { return }
            await BBSRegistry.shared.deleteThread(localID: id, guildID: guildID)
            try await sendThreadList(guildID: guildID, start: 0, connection: connection)

        case let .list(start):
            try await sendThreadList(guildID: guildID, start: start * 10, connection: connection)

        case let .listReply(id):
            try await sendThread(localID: id, guildID: guildID, connection: connection)

        case let .reply(id, body):
            guard await BBSRegistry.shared.thread(localID: id, guildID: guildID) != nil else { return }
            await BBSRegistry.shared.createReply(
                localID: id,
                guildID: guildID,
                posterCharacterID: characterID,
                body: body
            )
            try await sendThread(localID: id, guildID: guildID, connection: connection)

        case let .deleteReply(_, replyID):
            await BBSRegistry.shared.deleteReply(replyID: replyID, guildID: guildID)
        }
    }

    // MARK: - Private

    private func sendThreadList<Socket: MapleStorySocket, Database: ModelStorage>(
        guildID: GuildID,
        start: UInt32,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let allThreads = await BBSRegistry.shared.listThreads(guildID: guildID)
        let notice = allThreads.first { $0.notice }
        let nonNotice = allThreads.filter { !$0.notice }
        try await connection.send(BBSOperationResponse.threadList(
            notice: notice,
            threads: nonNotice,
            totalCount: UInt32(nonNotice.count),
            start: start
        ))
    }

    private func sendThread<Socket: MapleStorySocket, Database: ModelStorage>(
        localID: UInt32,
        guildID: GuildID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let thread = await BBSRegistry.shared.thread(localID: localID, guildID: guildID) else { return }
        let replies = await BBSRegistry.shared.replies(localID: localID, guildID: guildID)
        try await connection.send(BBSOperationResponse.showThread(localID: localID, thread: thread, replies: replies))
    }

    private func canModifyThread(
        localID: UInt32,
        guildID: GuildID,
        characterID: UInt32,
        guild: Guild
    ) async -> Bool {
        guard let thread = await BBSRegistry.shared.thread(localID: localID, guildID: guildID) else { return false }
        // Owner or guild master/junior master can modify
        if thread.posterCharacterID == characterID { return true }
        if let member = guild.members[guild.leaderID], member.characterID == guild.leaderID,
           guild.leaderID == guild.members.values.first(where: { $0.characterID.uuidString == characterID.description })?.characterID {
            return true
        }
        return false
    }

    private func isValidIcon(_ icon: UInt32) -> Bool {
        // Icons 0-2 are free; 100-106 (0x64-0x6a) require NX items
        return (icon <= 2) || (icon >= 0x64 && icon <= 0x6a)
    }
}
