//
//  DueyActionRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct DueyActionRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .dueyAction }

    public let type: UInt8

    /// Inventory type (send item only)
    public let inventoryType: UInt8?

    /// Inventory slot (send item only)
    public let slot: UInt8?

    /// Item quantity (send item only)
    public let quantity: Int16?

    /// Meso amount attached (send item only)
    public let mesos: UInt32?

    /// Recipient name (send item only)
    public let recipientName: String?
}

extension DueyActionRequest: MapleStoryDecodable {

    // C_SEND_ITEM type constant
    private static let sendItem: UInt8 = 0x02

    public init(from container: MapleStoryDecodingContainer) throws {
        self.type = try container.decode(UInt8.self)
        if type == Self.sendItem {
            self.inventoryType = try container.decode(UInt8.self)
            self.slot = try container.decode(UInt8.self)
            let _ = try container.decode(UInt8.self)
            self.quantity = try container.decode(Int16.self)
            self.mesos = try container.decode(UInt32.self)
            self.recipientName = try container.decode(String.self)
        } else {
            self.inventoryType = nil; self.slot = nil; self.quantity = nil
            self.mesos = nil; self.recipientName = nil
        }
    }
}
