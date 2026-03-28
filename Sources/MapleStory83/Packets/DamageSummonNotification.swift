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
}
