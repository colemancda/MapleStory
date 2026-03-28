//
//  SetFieldNotification.swift
//

import Foundation

/// Warp to Map / Set Field notification sent from server to client.
///
public struct SetFieldNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .setField }

    public let channel: Int32

    public let updated1: Int32

    public let updated2: UInt8

    public let mapID: Int32

    public let spawnPoint: UInt8

    public let hp: UInt16

    public let chasing: Bool

    public let spawnX: Int32?

    public let spawnY: Int32?

    public let time: Int64
}
