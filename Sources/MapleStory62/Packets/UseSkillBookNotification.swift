//
//  UseSkillBookNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Response to using a skill book (Mastery Book)
public struct UseSkillBookNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .useSkillBook }

    /// The skill ID this book affects
    public let skillID: UInt32

    /// Current skill level
    public let currentLevel: UInt8

    /// New mastery level (after using book)
    public let masteryLevel: UInt8

    /// Whether the book was successful
    public let success: Bool

    public init(
        skillID: UInt32,
        currentLevel: UInt8,
        masteryLevel: UInt8,
        success: Bool
    ) {
        self.skillID = skillID
        self.currentLevel = currentLevel
        self.masteryLevel = masteryLevel
        self.success = success
    }
}
