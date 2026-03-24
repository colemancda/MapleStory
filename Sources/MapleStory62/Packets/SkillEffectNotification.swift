//
//  SkillEffectNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent when a character uses a skill with visual effects
public struct SkillEffectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .skillEffect }

    /// Character ID using the skill
    public let characterID: UInt32

    /// Skill ID being used
    public let skillID: UInt32

    /// Skill level
    public let level: UInt8

    /// Effect flags
    public let flags: UInt8

    /// Animation speed
    public let speed: UInt8

    public init(characterID: UInt32, skillID: UInt32, level: UInt8, flags: UInt8, speed: UInt8) {
        self.characterID = characterID
        self.skillID = skillID
        self.level = level
        self.flags = flags
        self.speed = speed
    }
}
