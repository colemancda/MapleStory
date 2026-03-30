//
//  MovePlayerNotification.swift
//

import Foundation

/// Player movement broadcast to nearby players.
///
public struct MovePlayerNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .movePlayer }

    public let characterID: UInt32

    public let unknown: Int32

    public let movements: [Movement]

    public init(characterID: UInt32, unknown: Int32, movements: [Movement]) {
        self.characterID = characterID
        self.unknown = unknown
        self.movements = movements
    }
}
