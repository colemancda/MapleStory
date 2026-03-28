//
//  UseUpgradeScrollRequest.swift
//

import Foundation

public struct UseUpgradeScrollRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useUpgradeScroll }

    internal let value0: UInt32

    /// Scroll inventory slot
    public let slot: Int16

    /// Equipment destination slot
    public let destinationSlot: Int16

    /// White scroll in use (1 = yes)
    public let whiteScroll: Int16
}
