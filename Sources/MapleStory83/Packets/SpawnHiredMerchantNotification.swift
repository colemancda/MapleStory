//
//  SpawnHiredMerchantNotification.swift
//

import Foundation

/// Spawns a hired merchant on the map.
///
public struct SpawnHiredMerchantNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnHiredMerchant }

    public let ownerID: UInt32

    public let itemID: UInt32

    public let x: Int16

    public let y: Int16

    public let unknown: UInt16

    public let ownerName: String

    public let unknown2: UInt8

    public let objectID: UInt32

    public let description: String

    public let itemIDMod: UInt8
}
