//
//  BuddyListNotification.swift
//

import Foundation

public enum BuddyListNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .buddylist }

    case update([Buddy])
}

extension BuddyListNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .update(list):
            try container.encode(UInt8(7))
            try container.encode(list, forKey: CodingKeys.update)
            for _ in 0 ..< list.count {
                try container.encode(UInt32(0), isLittleEndian: true)
            }
        }
    }
}

public extension BuddyListNotification {

    struct Buddy: Codable, Equatable, Hashable, Identifiable, Sendable {
        public let id: UInt32
        public let name: CharacterName
        internal let value0: UInt8
        public let channel: Int32

        public init(id: UInt32, name: CharacterName, value0: UInt8, channel: Int32) {
            self.id = id
            self.name = name
            self.value0 = value0
            self.channel = channel
        }
    }
}

// MARK: - Message Notification

public struct BuddyListMessageNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .buddylist }

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

public extension BuddyListMessageNotification {
    static let buddyListFull = BuddyListMessageNotification(messageType: 11)
    static let otherBuddyListFull = BuddyListMessageNotification(messageType: 12)
    static let alreadyOnList = BuddyListMessageNotification(messageType: 13)
    static let characterNotFound = BuddyListMessageNotification(messageType: 15)
}
