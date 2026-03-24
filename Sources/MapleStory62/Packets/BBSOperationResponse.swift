//
//  BBSOperationResponse.swift
//
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation
import MapleStory

/// Guild bulletin board system server response.
public enum BBSOperationResponse: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .bbsOperation }

    /// Thread list page (sub-opcode 0x06)
    case threadList(notice: BBSThread?, threads: [BBSThread], totalCount: UInt32, start: UInt32)

    /// Show a single thread with its replies (sub-opcode 0x07)
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

    public init(
        localID: UInt32,
        posterCharacterID: UInt32,
        title: String,
        timestamp: UInt64,
        icon: UInt32,
        replyCount: UInt32 = 0,
        body: String = "",
        notice: Bool = false
    ) {
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

// MARK: - Codable (for standard Swift Codable compatibility; MapleStoryCodable overrides binary encoding)

extension BBSOperationResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case type, notice, threads, totalCount, start, localID, thread, replies
    }

    public init(from decoder: Decoder) throws {
        throw DecodingError.dataCorrupted(
            .init(codingPath: decoder.codingPath, debugDescription: "BBSOperationResponse is server-to-client only")
        )
    }

    public func encode(to encoder: Encoder) throws {
        // Encoding is handled by MapleStoryEncodable below
    }
}

// MARK: - MapleStoryEncodable

extension BBSOperationResponse: MapleStoryEncodable {

    // CodingKeys used as labels for string fields in the binary encoding container
    private enum StringKeys: String, CodingKey {
        case title, body, replyBody
    }

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .threadList(notice, threads, totalCount, start):
            try container.encode(UInt8(0x06))
            if let notice = notice {
                try container.encode(UInt8(1))
                try encodeThreadSummary(notice, to: container)
            } else {
                try container.encode(UInt8(0))
            }
            let pageOffset = Int(start)
            let page = Array(threads.dropFirst(pageOffset).prefix(10))
            try container.encode(totalCount)
            try container.encode(UInt32(page.count))
            for thread in page {
                try encodeThreadSummary(thread, to: container)
            }

        case let .showThread(localID, thread, replies):
            try container.encode(UInt8(0x07))
            try container.encode(localID)
            try container.encode(thread.posterCharacterID)
            try container.encode(thread.timestamp)
            try container.encode(thread.title, forKey: StringKeys.title)
            try container.encode(thread.body, forKey: StringKeys.body)
            try container.encode(thread.icon)
            try container.encode(UInt32(replies.count))
            for reply in replies {
                try container.encode(reply.id)
                try container.encode(reply.posterCharacterID)
                try container.encode(reply.timestamp)
                try container.encode(reply.body, forKey: StringKeys.replyBody)
            }
        }
    }

    private func encodeThreadSummary(_ thread: BBSThread, to container: MapleStoryEncodingContainer) throws {
        enum TitleKey: String, CodingKey { case title }
        try container.encode(thread.localID)
        try container.encode(thread.posterCharacterID)
        try container.encode(thread.title, forKey: TitleKey.title)
        try container.encode(thread.timestamp)
        try container.encode(thread.icon)
        try container.encode(thread.replyCount)
    }
}
