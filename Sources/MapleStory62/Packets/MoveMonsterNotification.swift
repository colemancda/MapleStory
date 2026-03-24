//
//  MoveMonsterNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Broadcast to all non-controlling clients when a mob moves.
/// Relayed from the controller's `MoveLifeRequest`. Opcode: `moveMonster` (0xB2)
public struct MoveMonsterNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveMonster }

    public let objectID: UInt32
    public let skillByte: UInt8
    public let skill: UInt8
    public let skillID: UInt8
    public let skillLevel: UInt8
    public let skillParam: UInt8
    public let startX: Int16
    public let startY: Int16
    public let movements: [Movement]

    public init(
        objectID: UInt32,
        skillByte: UInt8,
        skill: UInt8,
        skillID: UInt8,
        skillLevel: UInt8,
        skillParam: UInt8,
        startX: Int16,
        startY: Int16,
        movements: [Movement]
    ) {
        self.objectID = objectID
        self.skillByte = skillByte
        self.skill = skill
        self.skillID = skillID
        self.skillLevel = skillLevel
        self.skillParam = skillParam
        self.startX = startX
        self.startY = startY
        self.movements = movements
    }
}

extension MoveMonsterNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID)
        try container.encode(skillByte)
        try container.encode(skill)
        try container.encode(skillID)
        try container.encode(skillLevel)
        try container.encode(skillParam)
        try container.encode(UInt8(0))  // unknown
        try container.encode(UInt8(0))  // unknown
        try container.encode(UInt32(0)) // unknown
        try container.encode(startX)
        try container.encode(startY)
        try container.encode(UInt8(movements.count))
        for movement in movements {
            try movement.encode(to: container)
        }
    }
}
