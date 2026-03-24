//
//  OpenStorageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies client to open storage UI
public struct OpenStorageNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .openStorage }

    /// NPC ID (storage NPC)
    public let npcID: UInt32

    /// Mesos stored
    public let mesos: UInt32

    /// Number of slots used
    public let slots: UInt8

    /// Maximum slots
    public let maxSlots: UInt8

    /// Items in storage
    public let items: [StorageItemEntry]

    /// Create storage notification
    public init(
        npcID: UInt32,
        mesos: UInt32,
        slots: UInt8,
        maxSlots: UInt8,
        items: [StorageItemEntry]
    ) {
        self.npcID = npcID
        self.mesos = mesos
        self.slots = slots
        self.maxSlots = maxSlots
        self.items = items
    }
}

/// Storage item entry for client display
public struct StorageItemEntry: Codable, Equatable, Hashable, Sendable {

    /// Storage slot
    public let slot: Int8

    /// Item template ID
    public let itemID: UInt32

    /// Quantity
    public let quantity: UInt16

    /// Create storage item entry
    public init(slot: Int8, itemID: UInt32, quantity: UInt16) {
        self.slot = slot
        self.itemID = itemID
        self.quantity = quantity
    }
}
