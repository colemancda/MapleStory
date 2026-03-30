//
//  MoveMonsterNotification.swift
//

import Foundation

/// Monster movement broadcast to nearby clients.
///
public struct MoveMonsterNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveMonster }

    public let objectID: UInt32

    public let unknown: UInt8

    public let skillPossible: Bool

    public let skill: UInt8

    public let skillID: UInt8

    public let skillLevel: UInt8

    public let pOption: UInt16

    public let startX: Int16

    public let startY: Int16

    public let movements: [Movement]

    public init(
        objectID: UInt32, unknown: UInt8, skillPossible: Bool,
        skill: UInt8, skillID: UInt8, skillLevel: UInt8, pOption: UInt16,
        startX: Int16, startY: Int16, movements: [Movement]
    ) {
        self.objectID = objectID
        self.unknown = unknown
        self.skillPossible = skillPossible
        self.skill = skill
        self.skillID = skillID
        self.skillLevel = skillLevel
        self.pOption = pOption
        self.startX = startX
        self.startY = startY
        self.movements = movements
    }
}
