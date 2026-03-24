//
//  ItemMoveRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ItemMoveRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .itemMove }

    internal let value0: UInt32

    /// Inventory type (1=equip, 2=use, 3=setup, 4=etc, 5=cash)
    public let inventoryType: UInt8

    /// Source slot
    public let sourceSlot: Int16

    /// Destination slot (negative = equip slot)
    public let destinationSlot: Int16

    /// Quantity to move
    public let quantity: Int16
}
