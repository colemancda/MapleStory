//
//  DamagePlayerNotification.swift
//

import Foundation

/// Player takes damage notification broadcast to nearby clients.
///
public struct DamagePlayerNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damagePlayer }

    public let characterID: UInt32

    /// Skill type: -1 = normal mob, -2 = fall, -3 = poison/DoT, -4 = obstacle.
    public let skill: Int8

    /// Present only when skill == -3 (poison).
    public let unknown: UInt32?

    public let damage: Int32

    /// Not present when skill == -4.
    public let monsterIDFrom: UInt32?

    /// Not present when skill == -4.
    public let direction: UInt8?
}
