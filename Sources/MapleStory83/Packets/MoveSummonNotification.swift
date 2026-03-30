//
//  MoveSummonNotification.swift
//

import Foundation

/// Summon movement broadcast to nearby players.
///
public struct MoveSummonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveSummon }

    public let characterID: UInt32

    public let summonObjectID: UInt32

    public let startX: Int16

    public let startY: Int16

    public let movements: [Movement]

    public init(characterID: UInt32, summonObjectID: UInt32, startX: Int16, startY: Int16, movements: [Movement]) {
        self.characterID = characterID
        self.summonObjectID = summonObjectID
        self.startX = startX
        self.startY = startY
        self.movements = movements
    }
}
