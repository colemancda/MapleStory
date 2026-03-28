//
//  UseItemRequest.swift
//

import Foundation

public struct UseItemRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useItem }

    internal let value0: UInt32

    /// Inventory slot of the item
    public let slot: Int16

    /// Item ID to use
    public let itemID: UInt32
}
