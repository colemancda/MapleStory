//
//  MoveMonsterResponseNotification.swift
//

import Foundation

/// Server acknowledgement of a monster movement, sent back to the controlling client.
///
public struct MoveMonsterResponseNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveMonsterResponse }

    public let objectID: UInt32

    public let moveID: UInt16

    public let useSkills: Bool

    public let currentMP: UInt16

    public let skillID: UInt8

    public let skillLevel: UInt8

    public init(objectID: UInt32, moveID: UInt16, useSkills: Bool, currentMP: UInt16, skillID: UInt8, skillLevel: UInt8) {
        self.objectID = objectID
        self.moveID = moveID
        self.useSkills = useSkills
        self.currentMP = currentMP
        self.skillID = skillID
        self.skillLevel = skillLevel
    }
}
