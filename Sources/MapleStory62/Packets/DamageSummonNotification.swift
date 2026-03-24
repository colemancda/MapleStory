//
//  DamageSummonNotification.swift
//
//

import Foundation

public struct DamageSummonNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damageSummon }

    public let characterID: UInt32
    public let summonSkillID: UInt32
    public let unknownByte: UInt8
    public let damage: UInt32
    public let monsterIDFrom: UInt32

    public init(
        characterID: UInt32,
        summonSkillID: UInt32,
        unknownByte: UInt8,
        damage: UInt32,
        monsterIDFrom: UInt32
    ) {
        self.characterID = characterID
        self.summonSkillID = summonSkillID
        self.unknownByte = unknownByte
        self.damage = damage
        self.monsterIDFrom = monsterIDFrom
    }
}

extension DamageSummonNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(summonSkillID, isLittleEndian: true)
        try container.encode(unknownByte)
        try container.encode(damage, isLittleEndian: true)
        try container.encode(monsterIDFrom, isLittleEndian: true)
        try container.encode(UInt8(0))
    }
}

