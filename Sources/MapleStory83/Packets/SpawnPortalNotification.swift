//
//  SpawnPortalNotification.swift
//

import Foundation

/// Spawns a mystic door / portal for clients in the map.
///
public struct SpawnPortalNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnPortal }

    public let townID: UInt32

    public let targetID: UInt32

    public let x: Int16

    public let y: Int16
}
