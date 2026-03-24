//
//  MapItem.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// An item dropped on the ground.
public struct MapItem: Codable, Equatable, Hashable, Sendable {

    /// Unique object ID for this drop
    public let objectID: UInt32

    /// Item template ID (0 = meso)
    public let itemID: UInt32

    /// Amount (quantity for items, meso amount for mesos)
    public let quantity: UInt32

    /// Character ID who can pick up this drop (0 = anyone, drops to party)
    public let ownerID: UInt32

    /// Drop position on the map
    public let position: DropPosition

    /// When this drop expires (180 seconds from spawn)
    public let expiry: Date

    /// Map ID where this drop is located
    public let mapID: Map.ID

    /// Create a new map item
    public init(
        objectID: UInt32,
        itemID: UInt32,
        quantity: UInt32,
        ownerID: UInt32,
        position: DropPosition,
        expiry: Date,
        mapID: Map.ID
    ) {
        self.objectID = objectID
        self.itemID = itemID
        self.quantity = quantity
        self.ownerID = ownerID
        self.position = position
        self.expiry = expiry
        self.mapID = mapID
    }

    /// Check if this drop has expired
    public var isExpired: Bool {
        return Date() > expiry
    }

    /// Check if a character can pick up this drop
    public func canPickUp(by characterID: UInt32) -> Bool {
        // Anyone can pick up if ownerless
        if ownerID == 0 {
            return true
        }
        // Only owner (or party members in future) can pick up
        return ownerID == characterID
    }
}

/// Drop position on map
public struct DropPosition: Codable, Equatable, Hashable, Sendable {

    public let x: Int16
    public let y: Int16

    public init(x: Int16, y: Int16) {
        self.x = x
        self.y = y
    }
}
