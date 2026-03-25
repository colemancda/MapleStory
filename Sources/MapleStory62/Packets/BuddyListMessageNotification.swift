//
//  BuddyListMessageNotification.swift
//  MapleStory62
//
//  Created by Coleman on 3/24/26.
//

import Foundation

/// Buddy list message notification (error/status messages).
public struct BuddyListMessageNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .buddylist }

    /// Message type:
    /// - 11: Buddy list full
    /// - 12: Other person's buddy list full
    /// - 13: Buddy already on list
    /// - 15: Character not found
    public let messageType: UInt8

    public init(messageType: UInt8) {
        self.messageType = messageType
    }
}

extension BuddyListMessageNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(messageType)
    }
}

// MARK: - Message Types

public extension BuddyListMessageNotification {

    /// Buddy list is full
    static let buddyListFull = BuddyListMessageNotification(messageType: 11)

    /// Other person's buddy list is full
    static let otherBuddyListFull = BuddyListMessageNotification(messageType: 12)

    /// Buddy already on list (hidden)
    static let alreadyOnList = BuddyListMessageNotification(messageType: 13)

    /// Character not found
    static let characterNotFound = BuddyListMessageNotification(messageType: 15)
}
