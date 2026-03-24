//
//  BBSRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory
import MapleStory62

/// In-memory registry for guild bulletin board threads and replies.
public actor BBSRegistry {

    public static let shared = BBSRegistry()

    /// guildID → threads (localID 0 reserved for the notice thread)
    private var threads: [GuildID: [BBSThread]] = [:]

    /// globalThreadKey → replies
    private var replies: [UInt64: [BBSReply]] = [:]

    private var nextReplyID: UInt32 = 1

    private init() {}

    // MARK: - Threads

    public func listThreads(guildID: GuildID) -> [BBSThread] {
        threads[guildID] ?? []
    }

    public func thread(localID: UInt32, guildID: GuildID) -> BBSThread? {
        threads[guildID]?.first { $0.localID == localID }
    }

    @discardableResult
    public func createThread(
        guildID: GuildID,
        posterCharacterID: UInt32,
        notice: Bool,
        title: String,
        body: String,
        icon: UInt32
    ) -> BBSThread {
        var guildThreads = threads[guildID] ?? []
        let localID: UInt32
        if notice {
            // Notice always uses localID 0; replace existing notice if any
            guildThreads.removeAll { $0.notice }
            localID = 0
        } else {
            let maxID = guildThreads.filter { !$0.notice }.map { $0.localID }.max() ?? 0
            localID = maxID + 1
        }
        let thread = BBSThread(
            localID: localID,
            posterCharacterID: posterCharacterID,
            title: String(title.prefix(25)),
            timestamp: currentTimestamp(),
            icon: icon,
            replyCount: 0,
            body: String(body.prefix(600)),
            notice: notice
        )
        guildThreads.append(thread)
        threads[guildID] = guildThreads
        return thread
    }

    @discardableResult
    public func editThread(
        localID: UInt32,
        guildID: GuildID,
        title: String,
        body: String,
        icon: UInt32
    ) -> Bool {
        guard var guildThreads = threads[guildID],
              let idx = guildThreads.firstIndex(where: { $0.localID == localID }) else { return false }
        let old = guildThreads[idx]
        guildThreads[idx] = BBSThread(
            localID: old.localID,
            posterCharacterID: old.posterCharacterID,
            title: String(title.prefix(25)),
            timestamp: old.timestamp,
            icon: icon,
            replyCount: old.replyCount,
            body: String(body.prefix(600)),
            notice: old.notice
        )
        threads[guildID] = guildThreads
        return true
    }

    public func deleteThread(localID: UInt32, guildID: GuildID) {
        threads[guildID]?.removeAll { $0.localID == localID }
        replies.removeValue(forKey: replyKey(localID: localID, guildID: guildID))
    }

    // MARK: - Replies

    public func replies(localID: UInt32, guildID: GuildID) -> [BBSReply] {
        replies[replyKey(localID: localID, guildID: guildID)] ?? []
    }

    @discardableResult
    public func createReply(
        localID: UInt32,
        guildID: GuildID,
        posterCharacterID: UInt32,
        body: String
    ) -> BBSReply? {
        guard var guildThreads = threads[guildID],
              let idx = guildThreads.firstIndex(where: { $0.localID == localID }) else { return nil }

        let replyID = nextReplyID
        nextReplyID += 1

        let key = replyKey(localID: localID, guildID: guildID)
        let reply = BBSReply(
            id: replyID,
            threadID: UInt32(key & 0xFFFFFFFF),
            posterCharacterID: posterCharacterID,
            body: String(body.prefix(25)),
            timestamp: currentTimestamp()
        )
        var threadReplies = replies[key] ?? []
        threadReplies.append(reply)
        replies[key] = threadReplies
        guildThreads[idx].replyCount += 1
        threads[guildID] = guildThreads
        return reply
    }

    public func deleteReply(replyID: UInt32, guildID: GuildID) {
        for (key, var threadReplies) in replies {
            if let idx = threadReplies.firstIndex(where: { $0.id == replyID }) {
                threadReplies.remove(at: idx)
                replies[key] = threadReplies
                // Decrement reply count
                let localID = UInt32(key >> 32)
                if var guildThreads = threads[guildID],
                   let tIdx = guildThreads.firstIndex(where: { $0.localID == localID }),
                   guildThreads[tIdx].replyCount > 0 {
                    guildThreads[tIdx].replyCount -= 1
                    threads[guildID] = guildThreads
                }
                break
            }
        }
    }

    // MARK: - Private

    private func replyKey(localID: UInt32, guildID: GuildID) -> UInt64 {
        UInt64(localID) << 32 | UInt64(guildID)
    }

    private func currentTimestamp() -> UInt64 {
        UInt64(Date().timeIntervalSince1970 * 1000)
    }
}
