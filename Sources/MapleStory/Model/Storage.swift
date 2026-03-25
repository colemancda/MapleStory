//
//  Storage.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Character storage inventory
public struct Storage: Codable, Equatable, Hashable, Sendable {

    /// User ID that owns this storage
    public let userID: User.ID

    /// Mesos stored
    public var mesos: UInt32

    /// Number of slots used
    public var slots: UInt8 {
        UInt8(items.count)
    }

    /// Maximum slots (can be expanded)
    public var maxSlots: UInt8

    /// Items in storage (slot -> item)
    public var items: [Int8: InventoryItem]

    /// Create storage
    public init(
        userID: User.ID,
        mesos: UInt32 = 0,
        maxSlots: UInt8 = 16, // Default 16 slots 
        items: [Int8: InventoryItem] = [:]
    ) {
        self.userID = userID
        self.mesos = mesos
        self.maxSlots = maxSlots
        self.items = items
    }

    /// Check if storage has space for more items
    public var hasSpace: Bool {
        return items.count < Int(maxSlots)
    }
    
    /// Check if storage is full
    public var isFull: Bool {
        return items.count >= Int(maxSlots)
    }
}
