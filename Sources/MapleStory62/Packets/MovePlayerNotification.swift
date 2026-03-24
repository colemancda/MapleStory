//
//  MovePlayerNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct MovePlayerNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .movePlayer }

    /// Character integer ID (character.index).
    public let characterID: UInt32

    internal let flags: UInt32

    public let movements: [Movement]

    public init(characterID: UInt32, movements: [Movement]) {
        self.characterID = characterID
        self.flags = 0
        self.movements = movements
    }
}
