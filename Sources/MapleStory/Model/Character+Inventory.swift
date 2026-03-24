//
//  Character+Inventory.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Temporary inventory storage for characters (in-memory for now)
///
/// TODO: Integrate with Character model and database persistence
actor CharacterInventoryCache {

    public static let shared = CharacterInventoryCache()

    private var storage = [Character.ID: Inventory]()

    private init() {}

    public func inventory(for characterId: Character.ID) -> Inventory {
        return storage[characterId] ?? Inventory()
    }

    public func setInventory(_ inventory: Inventory, for characterId: Character.ID) {
        storage[characterId] = inventory
    }

    public func clearInventory(for characterId: Character.ID) {
        storage[characterId] = nil
    }
}

// MARK: - Character Inventory Extension (for Connection access)

public extension Character {

    /// Get the character's inventory from cache
    /// This is a temporary solution until inventory is stored in the database
    func getInventory() async -> Inventory {
        return await CharacterInventoryCache.shared.inventory(for: self.id)
    }

    /// Set the character's inventory in cache
    func setInventory(_ inventory: Inventory) async {
        await CharacterInventoryCache.shared.setInventory(inventory, for: self.id)
    }
}
