//
//  SpawnDoorNotification.swift
//

import Foundation

/// Spawns a mystic door on the map.
///
public struct SpawnDoorNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnDoor }

    public let launched: Bool

    public let ownerID: UInt32

    public let x: Int16

    public let y: Int16
}
