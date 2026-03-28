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
}
