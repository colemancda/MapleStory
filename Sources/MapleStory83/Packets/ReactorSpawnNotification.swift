//
//  ReactorSpawnNotification.swift
//

import Foundation

/// Spawns a reactor (interactive map object) for clients.
///
public struct ReactorSpawnNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .reactorSpawn }

    public let objectID: UInt32

    public let reactorID: UInt32

    public let state: UInt8

    public let x: Int16

    public let y: Int16

    public let unknown: UInt8

    public let unknown2: UInt16
}
