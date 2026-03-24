//
//  DropItemFromMapobjectNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies clients of a drop appearing on the map
public struct DropItemFromMapobjectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .dropItemFromMapobject }

    /// Source of the drop (0 = mob drop, 1 = player drop)
    public let source: UInt8

    /// Object ID of the dropped item
    public let objectID: UInt32

    /// Item template ID (0 = meso)
    public let itemID: UInt32

    /// Amount (quantity for items, meso amount for mesos)
    public let quantity: UInt32

    /// Character ID who can pick up this drop (0 = anyone)
    public let ownerID: UInt32

    /// Owner type (0 = free for all, 1 = owner only, 2 = party)
    public let ownerType: UInt8

    /// Drop X position
    public let x: Int16

    /// Drop Y position
    public let y: Int16

    /// Drop timestamp (milliseconds)
    public let timestamp: UInt32

    /// Create drop notification
    public init(
        source: UInt8,
        objectID: UInt32,
        itemID: UInt32,
        quantity: UInt32,
        ownerID: UInt32,
        ownerType: UInt8,
        x: Int16,
        y: Int16,
        timestamp: UInt32
    ) {
        self.source = source
        self.objectID = objectID
        self.itemID = itemID
        self.quantity = quantity
        self.ownerID = ownerID
        self.ownerType = ownerType
        self.x = x
        self.y = y
        self.timestamp = timestamp
    }
}
