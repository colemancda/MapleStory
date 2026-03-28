//
//  SpawnNPCNotification.swift
//

import Foundation

/// Spawn NPC notification sent to clients entering a map.
///
public struct SpawnNPCNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnNPC }

    public let objectID: UInt32

    public let npcID: UInt32

    public let x: Int16

    public let cy: Int16

    public let facingRight: Bool

    public let fh: Int16

    public let rx0: Int16

    public let rx1: Int16

    public let miniMap: UInt8
}
