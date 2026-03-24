//
//  GiveBuffNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies a client that they have received a buff
public struct GiveBuffNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .giveBuff }

    /// Skill ID that applied this buff
    public let skillID: UInt32

    /// Skill level
    public let level: UInt8

    /// Buff duration in seconds
    public let duration: UInt32

    /// Buff stat effects (packed as per v62 protocol)
    public let buffStats: UInt32

    /// Create buff notification
    public init(
        skillID: UInt32,
        level: UInt8,
        duration: UInt32,
        buffStats: UInt32
    ) {
        self.skillID = skillID
        self.level = level
        self.duration = duration
        self.buffStats = buffStats
    }
}
