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
}
