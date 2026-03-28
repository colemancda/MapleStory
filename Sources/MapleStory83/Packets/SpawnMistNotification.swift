//
//  SpawnMistNotification.swift
//

import Foundation

/// Spawn a mist (poison cloud, smoke screen, etc.) on the map.
///
/// mistType: 0 = mob mist, 1 = player poison, 2 = smokescreen, 4 = recovery
public struct SpawnMistNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnMist }

    public let objectID: UInt32

    public let mistType: UInt32

    public let ownerID: UInt32

    public let skillID: UInt32

    public let skillLevel: UInt8

    public let skillDelay: UInt16

    public let left: Int32

    public let top: Int32

    public let right: Int32

    public let bottom: Int32

    public let unknown: UInt32
}
