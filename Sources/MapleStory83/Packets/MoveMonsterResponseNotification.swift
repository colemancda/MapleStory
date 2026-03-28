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
}
