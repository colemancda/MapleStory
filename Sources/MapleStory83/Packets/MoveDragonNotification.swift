//
//  MoveDragonNotification.swift
//

import Foundation

/// Moves the Evan dragon (Mir) for nearby clients.
///
public struct MoveDragonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveDragon }

    public let ownerCharacterID: UInt32

    public let startX: Int16

    public let startY: Int16

    public let movements: [Movement]
}
