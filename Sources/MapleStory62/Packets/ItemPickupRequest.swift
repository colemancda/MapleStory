//
//  ItemPickupRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ItemPickupRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .itemPickup }

    internal let value0: UInt8

    internal let value1: UInt32

    internal let value2: UInt32

    /// Map object ID of the dropped item
    public let objectID: UInt32
}
