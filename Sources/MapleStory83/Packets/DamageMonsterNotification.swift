//
//  DamageMonsterNotification.swift
//

import Foundation

/// Monster takes damage or is healed notification.
///
public struct DamageMonsterNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damageMonster }

    public let objectID: UInt32

    public let unknown: UInt8

    public let damage: Int32

    public let currentHP: UInt32

    public let maxHP: UInt32
}
