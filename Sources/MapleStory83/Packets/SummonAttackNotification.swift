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

        public init(monsterObjectID: UInt32, unknown: UInt8, damage: Int32) {
            self.monsterObjectID = monsterObjectID
            self.unknown = unknown
            self.damage = damage
        }
    }

    public init(characterID: UInt32, objectID: UInt32, numAttacked: UInt8) {
        self.characterID = characterID
        self.summonObjectID = objectID
        self.charLevel = 0
        self.direction = 0
        self.targets = (0 ..< numAttacked).map { _ in Target(monsterObjectID: 0, unknown: 0, damage: 0) }
    }

    public init(characterID: UInt32, summonObjectID: UInt32, charLevel: UInt8, direction: UInt8, targets: [Target]) {
        self.characterID = characterID
        self.summonObjectID = summonObjectID
        self.charLevel = charLevel
        self.direction = direction
        self.targets = targets
    }
}
