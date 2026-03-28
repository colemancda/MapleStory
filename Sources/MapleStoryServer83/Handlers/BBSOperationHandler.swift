//
//  BBSOperationHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct BBSOperationHandler: PacketHandler {

    public typealias Packet = MapleStory83.BBSOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard let guild = try await GuildRegistry.shared.guild(for: character.id, in: connection.database) else { return }
        let guildID: GuildEntity.ID = guild.id
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
        guildID: GuildEntity.ID,
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
        guildID: GuildEntity.ID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let thread = await BBSRegistry.shared.thread(localID: localID, guildID: guildID) else { return }
        let replies = await BBSRegistry.shared.replies(localID: localID, guildID: guildID)
        try await connection.send(BBSOperationResponse.showThread(localID: localID, thread: thread, replies: replies))
    }

    private func canModifyThread(
        localID: UInt32,
        guildID: GuildEntity.ID,
        characterID: UInt32,
        guild: GuildEntity
    ) async -> Bool {
        guard let thread = await BBSRegistry.shared.thread(localID: localID, guildID: guildID) else { return false }
        if thread.posterCharacterID == characterID { return true }
        return false
    }

    private func isValidIcon(_ icon: UInt32) -> Bool {
        return (icon <= 2) || (icon >= 0x64 && icon <= 0x6a)
    }
}
