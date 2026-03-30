//
//  DamageSummonNotification.swift
//

import Foundation

/// A summon object takes damage notification.
///
public struct DamageSummonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damageSummon }

    public let characterID: UInt32

    public let summonObjectID: UInt32

    public let unknown: UInt8

    public let damage: Int32

    public let monsterIDFrom: UInt32

    public let unknown2: UInt8

    public init(characterID: UInt32, summonObjectID: UInt32, unknown: UInt8, damage: Int32, monsterIDFrom: UInt32, unknown2: UInt8) {
        self.characterID = characterID
        self.summonObjectID = summonObjectID
        self.unknown = unknown
        self.damage = damage
        self.monsterIDFrom = monsterIDFrom
        self.unknown2 = unknown2
    }
}
