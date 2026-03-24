//
//  SummonSkillNotification.swift
//
//

import Foundation

public struct SummonSkillNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .summonSkill }

    public let characterID: UInt32
    public let summonSkillID: UInt32
    public let newStance: UInt8

    public init(characterID: UInt32, summonSkillID: UInt32, newStance: UInt8) {
        self.characterID = characterID
        self.summonSkillID = summonSkillID
        self.newStance = newStance
    }
}

extension SummonSkillNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(summonSkillID, isLittleEndian: true)
        try container.encode(newStance)
    }
}

