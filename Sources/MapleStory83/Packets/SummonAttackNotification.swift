//
//  SummonAttackNotification.swift
//

import Foundation

/// Summon attack broadcast to nearby players.
///
public struct SummonAttackNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .summonAttack }

    public let characterID: UInt32

    public let summonObjectID: UInt32

    public let charLevel: UInt8

    public let direction: UInt8

    public let targets: [Target]

    public struct Target: Codable, Equatable, Hashable, Sendable {

        public let monsterObjectID: UInt32

        public let unknown: UInt8

        public let damage: Int32
    }
}
