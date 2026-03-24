//
//  ItemSortRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ItemSortRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .itemSort }

    internal let value0: UInt32

    /// Inventory type to sort
    public let inventoryType: UInt8
}
