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

/// Handles guild BBS (Bulletin Board System) operations.
///
/// # Guild BBS System
///
/// The BBS allows guild members to post and reply to messages, similar to a forum.
/// Each guild has its own BBS with threads and replies.
///
/// # Operations
///
/// ## New Thread
/// - Creates a new BBS thread
/// - Requires valid icon (0-2 or 0x64-0x6a)
/// - Any guild member can create threads
///
/// ## Edit Thread
/// - Modifies existing thread title, body, and icon
/// - Only thread owner can edit
/// - Guild masters/juniors can edit any thread
///
/// ## Delete Thread
/// - Removes a thread and all its replies
/// - Only thread owner can delete
/// - Guild masters/juniors can delete any thread
///
/// ## List Threads
/// - Returns paginated list of guild BBS threads
/// - Notice thread always displayed first (pinned)
/// - Regular threads paginated (10 per page)
///
/// ## View Thread
/// - Returns full thread content and all replies
/// - Shows thread title, body, icon, and replies
///
/// ## Reply to Thread
/// - Adds a reply to an existing thread
/// - Any guild member can reply
///
/// ## Delete Reply
/// - Removes a specific reply from a thread
/// - Only guild masters/juniors can delete replies
///
/// # Icons
///
/// Thread icons:
/// - **0-2**: Free icons (no NX required)
/// - **0x64-0x6a (100-106)**: NX cash shop icons
///
/// # Permissions
///
/// Thread modification permissions:
/// - ✅ Thread owner: Can edit/delete own thread
/// - ✅ Guild master: Can edit/delete any thread/reply
/// - ✅ Junior master: Can edit/delete any thread/reply
/// - ❌ Regular member: Cannot edit/delete others' threads
///
/// # Response
///
/// - **New/Edit/Delete/Reply**: Sends updated thread list or thread view
/// - **List**: Sends paginated thread list with notice thread first
/// - **View**: Sends full thread with all replies
public struct BBSOperationHandler: PacketHandler {

    public typealias Packet = MapleStory62.BBSOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Character must be in a guild
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
        // Owner can modify
        if thread.posterCharacterID == characterID { return true }
        return false
    }

    private func isValidIcon(_ icon: UInt32) -> Bool {
        // Icons 0-2 are free; 100-106 (0x64-0x6a) require NX items
        return (icon <= 2) || (icon >= 0x64 && icon <= 0x6a)
    }
}
