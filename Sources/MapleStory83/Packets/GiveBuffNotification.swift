//
//  GiveBuffNotification.swift
//

import Foundation
import MapleStory

/// Notifies a client that they have received a buff.
public struct GiveBuffNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .giveBuff }

    public let skillID: UInt32
    public let level: UInt8
    public let duration: UInt32
    public let buffStats: UInt32

    public init(skillID: UInt32, level: UInt8, duration: UInt32, buffStats: UInt32) {
        self.skillID = skillID
        self.level = level
        self.duration = duration
        self.buffStats = buffStats
    }
}

extension GiveBuffNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(buffStats, isLittleEndian: true)
        try container.encode(skillID, isLittleEndian: true)
        try container.encode(level)
        try container.encode(duration, isLittleEndian: true)
    }
}
