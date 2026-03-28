//
//  SpawnNPCRequestControllerNotification.swift
//

import Foundation

/// Request NPC controller assignment, includes minimap visibility flag.
///
public struct SpawnNPCRequestControllerNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnNPCRequestController }

    public let mode: UInt8

    public let objectID: UInt32

    public let npcID: UInt32

    public let x: Int16

    public let cy: Int16

    public let facingRight: Bool

    public let fh: Int16

    public let rx0: Int16

    public let rx1: Int16

    public let miniMap: Bool
}
