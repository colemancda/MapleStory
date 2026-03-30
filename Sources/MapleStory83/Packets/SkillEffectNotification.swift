//
//  SkillEffectNotification.swift
//

import Foundation

/// Sent when a character uses a skill with visual effects.
public struct SkillEffectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .skillEffect }

    public let characterID: UInt32
    public let skillID: UInt32
    public let level: UInt8
    public let flags: UInt8
    public let speed: UInt8

    public init(characterID: UInt32, skillID: UInt32, level: UInt8, flags: UInt8, speed: UInt8) {
        self.characterID = characterID
        self.skillID = skillID
        self.level = level
        self.flags = flags
        self.speed = speed
    }
}

extension SkillEffectNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(skillID, isLittleEndian: true)
        try container.encode(level)
        try container.encode(flags)
        try container.encode(speed)
    }
}
