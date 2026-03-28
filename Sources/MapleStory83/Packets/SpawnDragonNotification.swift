//
//  SpawnDragonNotification.swift
//

import Foundation

/// Spawns the Evan dragon (Mir) for nearby clients.
///
public struct SpawnDragonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnDragon }

    public let ownerCharacterID: UInt32

    public let x: Int16

    public let unknown1: Int16

    public let y: Int16

    public let unknown2: Int16

    public let stance: UInt8

    public let unknown3: UInt8

    public let jobID: UInt16
}
