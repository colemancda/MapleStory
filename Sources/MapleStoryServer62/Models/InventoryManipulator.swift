//
//  InventoryManipulator.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Actor that handles all inventory operations (thread-safe).
public actor InventoryManipulator {

    // MARK: - Add Items

    /// Add an item by ID to the character's inventory.
    /// - Parameters:
    ///   - itemId: Item template ID
    ///   - quantity: Amount to add (for stackable items)
    ///   - character: Character to add item to
    /// - Returns: The slot where the item was added, or nil if failed
    @discardableResult
    public func addById(
        _ itemId: UInt32,
        quantity: UInt16 = 1,
        to character: Character
    ) async throws -> Int8? {
        var inventory = await character.getInventory()

        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemId) else {
            return nil // Invalid item ID
        }

        // Check if it's equipment (non-stackable)
        if await isEquip(itemId) {
            guard let slot = inventory.findEmptySlot(in: inventoryType) else {
                return nil // No space
            }
            let item = await createEquip(itemId, slot: slot)
            inventory[inventoryType][slot] = item
        } else {
            // Stackable item - try to stack with existing or find empty slot
            guard let slot = try await findSlotForItem(itemId, quantity: quantity, in: inventory, type: inventoryType) else {
                return nil // No space
            }

            if var existing = inventory[inventoryType][slot] {
                // Add to existing stack
                let maxStack = await ItemDataCache.shared.maxStackSize(for: itemId)
                let newQuantity = min(UInt32(existing.quantity) + UInt32(quantity), UInt32(maxStack))
                existing.quantity = UInt16(newQuantity)
                inventory[inventoryType][slot] = existing
            } else {
                // Create new stack
                let item = InventoryItem(id: UUID(), itemId: itemId, slot: slot, quantity: quantity)
                inventory[inventoryType][slot] = item
            }
        }

        await character.setInventory(inventory)
        return inventory[inventoryType].keys.first
    }

    /// Add an item from a drop (e.g., mob drop or ground pickup).
    @discardableResult
    public func addFromDrop(
        _ itemId: UInt32,
        quantity: UInt16,
        to character: Character
    ) async throws -> Int8? {
        return try await addById(itemId, quantity: quantity, to: character)
    }

    // MARK: - Remove Items

    /// Remove an item by ID from the character's inventory.
    /// - Parameters:
    ///   - itemId: Item template ID
    ///   - quantity: Amount to remove
    ///   - character: Character to remove item from
    /// - Returns: true if successful
    @discardableResult
    public func removeById(
        _ itemId: UInt32,
        quantity: UInt16 = 1,
        from character: Character
    ) async throws -> Bool {
        var inventory = await character.getInventory()

        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemId) else {
            return false
        }

        var remainingToRemove = quantity

        // Find all stacks of this item
        let slots: [(Int8, InventoryItem)] = inventory[inventoryType]
            .filter { $0.value.itemId == itemId }
            .sorted { $0.key < $1.key }

        for (slot, item) in slots {
            if remainingToRemove <= 0 {
                break
            }

            if item.quantity <= remainingToRemove {
                // Remove entire stack
                inventory[inventoryType][slot] = nil
                remainingToRemove -= item.quantity
            } else {
                // Reduce stack size
                var updated = item
                updated.quantity -= remainingToRemove
                inventory[inventoryType][slot] = updated
                remainingToRemove = 0
            }
        }

        await character.setInventory(inventory)
        return remainingToRemove == 0
    }

    // MARK: - Move Items

    /// Move an item to a different slot.
    public func move(
        _ item: InventoryItem,
        toSlot targetSlot: Int8,
        in inventoryType: InventoryType,
        for character: Character
    ) async throws {
        var inventory = await character.getInventory()

        guard var item = inventory[inventoryType][item.slot] else {
            return // Item doesn't exist
        }

        // Check if target slot is empty or occupied
        let targetItem = inventory[inventoryType][targetSlot]

        // Move item
        inventory[inventoryType][item.slot] = targetItem
        item.slot = targetSlot
        inventory[inventoryType][targetSlot] = item

        await character.setInventory(inventory)
    }

    /// Equip an item from inventory to equipment slot.
    public func equip(
        _ item: InventoryItem,
        for character: Character
    ) async throws {
        guard var equipData = item.equip else {
            return // Not equipment
        }

        var inventory = await character.getInventory()

        // Remove from inventory
        inventory[.equip][item.slot] = nil

        // Move to equipped slot (negative slot)
        equipData.slot = -equipmentSlot(for: item.itemId)
        var equippedItem = item
        equippedItem.slot = equipData.slot
        equippedItem.equip = equipData
        inventory[.equip][equipData.slot] = equippedItem

        await character.setInventory(inventory)
    }

    /// Unequip an item back to inventory.
    public func unequip(
        _ item: InventoryItem,
        for character: Character
    ) async throws {
        var inventory = await character.getInventory()

        // Find first empty slot in equip inventory
        guard let targetSlot = inventory.findEmptySlot(in: .equip) else {
            return // No space
        }

        // Remove from equipped slot
        inventory[.equip][item.slot] = nil

        // Move to inventory slot
        var unequippedItem = item
        unequippedItem.slot = targetSlot
        if var equipData = unequippedItem.equip {
            equipData.slot = targetSlot
            unequippedItem.equip = equipData
        }
        inventory[.equip][targetSlot] = unequippedItem

        await character.setInventory(inventory)
    }

    // MARK: - Space Checking

    /// Check if character has space for an item.
    public func checkSpace(
        _ itemId: UInt32,
        quantity: UInt16 = 1,
        for character: Character
    ) async throws -> Bool {
        let inventory = await character.getInventory()

        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemId) else {
            return false
        }

        if await isEquip(itemId) {
            return inventory.findEmptySlot(in: inventoryType) != nil
        } else {
            return try await findSlotForItem(itemId, quantity: quantity, in: inventory, type: inventoryType) != nil
        }
    }

    // MARK: - Helpers

    private func findSlotForItem(
        _ itemId: UInt32,
        quantity: UInt16,
        in inventory: Inventory,
        type: InventoryType
    ) async throws -> Int8? {
        // First, try to find an existing stack to add to
        for (slot, item) in inventory[type] {
            if item.itemId == itemId {
                let maxStack = await ItemDataCache.shared.maxStackSize(for: itemId)
                if item.quantity < maxStack {
                    return slot // Can add to this stack
                }
            }
        }

        // No existing stack, find empty slot
        return inventory.findEmptySlot(in: type)
    }

    private func isEquip(_ itemId: UInt32) async -> Bool {
        return await ItemDataCache.shared.equip(id: itemId) != nil
    }

    private func createEquip(_ itemId: UInt32, slot: Int8) async -> InventoryItem {
        let wzEquip = await ItemDataCache.shared.equip(id: itemId)

        let equipData = EquipData(
            slot: slot,
            str: wzEquip?.str ?? 0,
            dex: wzEquip?.dex ?? 0,
            int: wzEquip?.int ?? 0,
            luk: wzEquip?.luk ?? 0,
            hp: wzEquip?.hp ?? 0,
            mp: wzEquip?.mp ?? 0,
            weaponAttack: wzEquip?.weaponAttack ?? 0,
            magicAttack: wzEquip?.magicAttack ?? 0,
            weaponDefense: wzEquip?.weaponDefense ?? 0,
            magicDefense: wzEquip?.magicDefense ?? 0,
            accuracy: wzEquip?.accuracy ?? 0,
            avoid: wzEquip?.avoid ?? 0,
            speed: wzEquip?.speed ?? 0,
            jump: wzEquip?.jump ?? 0,
            slots: wzEquip?.slots ?? 7
        )

        return InventoryItem(id: UUID(), itemId: itemId, slot: slot, quantity: 1, equip: equipData)
    }

    private func equipmentSlot(for itemId: UInt32) -> Int8 {
        // Map item ID to equipment slot
        let prefix = itemId / 1000

        switch prefix {
        // Hats
        case 100000...100999:
            return -1

        // Face accessories
        case 10000...10099:
            return -2

        // Eye accessories
        case 10200...10299:
            return -3

        // Earrings
        case 10300...10399:
            return -4

        // Tops/Coats
        case 104000...104999, 105000...105999:
            return -5

        // Bottoms/Pants
        case 106000...106999:
            return -6

        // Shoes
        case 107000...107999:
            return -7

        // Gloves
        case 108000...108999:
            return -8

        // Capes
        case 110000...110999:
            return -9

        // Shields
        case 109000...109999:
            return -10

        // Weapons
        case 121000...121999, 122000...122999,
             123000...123999, 124000...124999,
             130000...130999, 131000...131999,
             132000...132999, 133000...133999,
             134000...134999, 137000...137999,
             138000...138999, 140000...140999,
             141000...141999, 142000...142999,
             143000...143999, 144000...144999,
             145000...145999, 146000...146999,
             147000...147999, 148000...148999,
             149000...149999:
            return -11

        default:
            return -1 // Default to hat slot
        }
    }
}
