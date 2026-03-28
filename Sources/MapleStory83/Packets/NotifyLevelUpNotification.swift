//
//  NotifyLevelUpNotification.swift
//

import Foundation

/// Broadcast level-up message to guild or family.
///
public struct NotifyLevelUpNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .notifyLevelup }

    /// 0 = guild, 1 = family.
    public let type: UInt8

    public let level: UInt32

    public let characterName: String
}
