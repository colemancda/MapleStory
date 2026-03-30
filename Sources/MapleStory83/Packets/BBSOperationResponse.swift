//
//  BBSOperationResponse.swift
//

import Foundation
import MapleStory

/// Guild bulletin board system server response.
public enum BBSOperationResponse: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .guildBbsPacket }

    case threadList(notice: BBSThread?, threads: [BBSThread], totalCount: UInt32, start: UInt32)
    case showThread(localID: UInt32, thread: BBSThread, replies: [BBSReply])
}

// MARK: - Models

public struct BBSThread: Codable, Equatable, Hashable, Sendable {
    public let localID: UInt32
    public let posterCharacterID: UInt32
    public let title: String
    public let timestamp: UInt64
    public let icon: UInt32
    public var replyCount: UInt32
    public let body: String
    public let notice: Bool

    public init(localID: UInt32, posterCharacterID: UInt32, title: String, timestamp: UInt64, icon: UInt32, replyCount: UInt32 = 0, body: String = "", notice: Bool = false) {
        self.localID = localID
        self.posterCharacterID = posterCharacterID
        self.title = title
        self.timestamp = timestamp
        self.icon = icon
        self.replyCount = replyCount
        self.body = body
        self.notice = notice
    }
}

public struct BBSReply: Codable, Equatable, Hashable, Sendable {
    public let id: UInt32
    public let threadID: UInt32
    public let posterCharacterID: UInt32
    public let body: String
    public let timestamp: UInt64

    public init(id: UInt32, threadID: UInt32, posterCharacterID: UInt32, body: String, timestamp: UInt64) {
        self.id = id
        self.threadID = threadID
        self.posterCharacterID = posterCharacterID
        self.body = body
        self.timestamp = timestamp
    }
}

extension BBSOperationResponse: MapleStoryEncodable {

    private enum TitleKey: String, CodingKey { case title }
    private enum BodyKey: String, CodingKey { case body }
    private enum ReplyBodyKey: String, CodingKey { case replyBody }

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .threadList(notice, threads, totalCount, start):
            try container.encode(UInt8(0x06))
            if let notice {
                try container.encode(UInt8(1))
                try encodeThreadSummary(notice, to: container)
            } else {
                try container.encode(UInt8(0))
            }
            let page = Array(threads.dropFirst(Int(start)).prefix(10))
            try container.encode(totalCount, isLittleEndian: true)
            try container.encode(UInt32(page.count), isLittleEndian: true)
            for thread in page {
                try encodeThreadSummary(thread, to: container)
            }

        case let .showThread(localID, thread, replies):
            try container.encode(UInt8(0x07))
            try container.encode(localID, isLittleEndian: true)
            try container.encode(thread.posterCharacterID, isLittleEndian: true)
            try container.encode(thread.timestamp, isLittleEndian: true)
            try container.encode(thread.title, forKey: TitleKey.title)
            try container.encode(thread.body, forKey: BodyKey.body)
            try container.encode(thread.icon, isLittleEndian: true)
            try container.encode(UInt32(replies.count), isLittleEndian: true)
            for reply in replies {
                try container.encode(reply.id, isLittleEndian: true)
                try container.encode(reply.posterCharacterID, isLittleEndian: true)
                try container.encode(reply.timestamp, isLittleEndian: true)
                try container.encode(reply.body, forKey: ReplyBodyKey.replyBody)
            }
        }
    }

    private func encodeThreadSummary(_ thread: BBSThread, to container: MapleStoryEncodingContainer) throws {
        try container.encode(thread.localID, isLittleEndian: true)
        try container.encode(thread.posterCharacterID, isLittleEndian: true)
        try container.encode(thread.title, forKey: TitleKey.title)
        try container.encode(thread.timestamp, isLittleEndian: true)
        try container.encode(thread.icon, isLittleEndian: true)
        try container.encode(thread.replyCount, isLittleEndian: true)
    }
}
