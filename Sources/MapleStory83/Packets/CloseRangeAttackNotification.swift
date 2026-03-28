//
//  CloseRangeAttackNotification.swift
//

import Foundation

/// Close-range (melee) attack broadcast to nearby players.
///
public struct CloseRangeAttackNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .closeRangeAttack }

    public let characterID: UInt32

    public let numAttackedAndDamage: UInt8

    public let unknown: UInt8

    public let skillLevel: UInt8

    public let skillID: UInt32?

    public let display: UInt8

    public let direction: UInt8

    public let stance: UInt8

    public let speed: UInt8

    public let unknown2: UInt8

    public let projectile: UInt32

    public let targets: [AttackTarget]

    public struct AttackTarget: Codable, Equatable, Hashable, Sendable {

        public let monsterObjectID: UInt32

        public let unknown: UInt8

        public let damageLines: [Int32]
    }
}
