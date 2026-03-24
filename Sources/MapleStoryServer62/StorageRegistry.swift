//
//  StorageRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry tracking storage for all users.
public actor StorageRegistry {

    public static let shared = StorageRegistry()

    /// User ID -> Storage
    private var storage: [User.ID: Storage] = [:]

    private init() {}

    // MARK: - Storage Management

    /// Get or create storage for a user.
    public func storage(userID: User.ID) -> Storage {
        if let existing = storage[userID] {
            return existing
        }
        // Create new storage
        let newStorage = Storage(
            userID: userID,
            mesos: 0,
            maxSlots: 4, // Default 4 slots
            items: [:]
        )
        storage[userID] = newStorage
        return newStorage
    }

    /// Update storage for a user.
    public func setStorage(_ storage: Storage, userID: User.ID) {
        self.storage[userID] = storage
    }

    /// Add mesos to storage.
    public func addMesos(_ amount: UInt32, to userID: User.ID) {
        var stor = storage(userID: userID)
        stor.mesos = stor.mesos + amount
        storage[userID] = stor
    }

    /// Remove mesos from storage.
    public func removeMesos(_ amount: UInt32, from userID: User.ID) -> Bool {
        var stor = storage(userID: userID)
        guard stor.mesos >= amount else {
            return false
        }
        stor.mesos = stor.mesos - amount
        storage[userID] = stor
        return true
    }

    /// Deposit item into storage.
    public func depositItem(
        _ item: InventoryItem,
        to userID: User.ID
    ) -> Int8? {
        var stor = storage(userID: userID)
        guard stor.hasSpace else {
            return nil // No space
        }

        // Find empty slot
        for slot in 0..<Int8(stor.maxSlots) {
            if stor.items[slot] == nil {
                var updatedItem = item
                updatedItem.slot = slot
                stor.items[slot] = updatedItem
                storage[userID] = stor
                return slot
            }
        }

        return nil // Should not reach here if hasSpace is true
    }

    /// Withdraw item from storage.
    public func withdrawItem(
        slot: Int8,
        from userID: User.ID
    ) -> InventoryItem? {
        var stor = storage(userID: userID)
        guard let item = stor.items.removeValue(forKey: slot) else {
            return nil
        }
        storage[userID] = stor
        return item
    }

    /// Get item from storage without removing it.
    public func item(
        slot: Int8,
        userID: User.ID
    ) -> InventoryItem? {
        let stor = storage(userID: userID)
        return stor.items[slot]
    }
}
