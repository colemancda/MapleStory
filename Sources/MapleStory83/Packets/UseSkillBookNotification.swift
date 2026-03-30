//
//  UseSkillBookNotification.swift
//

import Foundation

/// Response to using a skill book (Mastery Book).
/// Broadcast to the map to show the animation.
public struct UseSkillBookNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .skillLearnItemResult }

    public let characterID: UInt32
    public let skillID: UInt32
    public let maxLevel: UInt32
    public let canUse: Bool
    public let success: Bool

    public init(characterID: UInt32, skillID: UInt32, maxLevel: UInt32, canUse: Bool, success: Bool) {
        self.characterID = characterID
        self.skillID = skillID
        self.maxLevel = maxLevel
        self.canUse = canUse
        self.success = success
    }
}

extension UseSkillBookNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(UInt8(1))
        try container.encode(skillID, isLittleEndian: true)
        try container.encode(maxLevel, isLittleEndian: true)
        try container.encode(canUse)
        try container.encode(success)
    }
}
