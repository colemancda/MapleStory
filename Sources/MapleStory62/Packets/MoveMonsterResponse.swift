//
//  MoveMonsterResponse.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent back to the controlling client after receiving a `MoveLifeRequest`.
/// Opcode: `moveMonsterResponse` (0xB3)
public struct MoveMonsterResponse: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveMonsterResponse }

    public let objectID: UInt32
    public let moveID: UInt16
    /// Whether the mob used a skill this tick.
    public let useSkill: Bool
    /// Mob's current MP (used by client for skill availability checks).
    public let mp: UInt16
    public let skillID: UInt8
    public let skillLevel: UInt8

    public init(objectID: UInt32, moveID: UInt16, useSkill: Bool = false, mp: UInt16 = 0, skillID: UInt8 = 0, skillLevel: UInt8 = 0) {
        self.objectID = objectID
        self.moveID = moveID
        self.useSkill = useSkill
        self.mp = mp
        self.skillID = skillID
        self.skillLevel = skillLevel
    }
}

extension MoveMonsterResponse: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID)
        try container.encode(moveID)
        try container.encode(useSkill)
        try container.encode(mp)
        try container.encode(skillID)
        try container.encode(skillLevel)
    }
}
