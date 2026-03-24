//
//  CancelSkillEffectNotification.swift
//
//

import Foundation

public struct CancelSkillEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelSkillEffect }

    public let characterID: UInt32
    public let skillID: UInt32

    public init(characterID: UInt32, skillID: UInt32) {
        self.characterID = characterID
        self.skillID = skillID
    }
}

extension CancelSkillEffectNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(skillID, isLittleEndian: true)
    }
}

