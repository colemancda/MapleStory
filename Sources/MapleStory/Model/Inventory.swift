//
//  Inventory.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Player inventory containing all 5 inventory bags.
public struct Inventory: Codable, Equatable, Hashable, Sendable {

    /// Equippable items (armor, weapons, accessories)
    public var equip: [Int8: InventoryItem]

    /// Consumable items (potions, foods, scrolls)
    public var use: [Int8: InventoryItem]

    /// Setup items (arrows, throwing stars, bullets)
    public var setup: [Int8: InventoryItem]

    /// Etc items (ores, monster pieces, quest items)
    public var etc: [Int8: InventoryItem]

    /// Cash shop items
    public var cash: [Int8: InventoryItem]

    public init(
        equip: [Int8: InventoryItem] = [:],
        use: [Int8: InventoryItem] = [:],
        setup: [Int8: InventoryItem] = [:],
        etc: [Int8: InventoryItem] = [:],
        cash: [Int8: InventoryItem] = [:]
    ) {
        self.equip = equip
        self.use = use
        self.setup = setup
        self.etc = etc
        self.cash = cash
    }
}

// MARK: - Inventory Type Enum

public enum InventoryType: UInt8, Codable, Sendable {
    case equip = 1
    case use = 2
    case setup = 3
    case etc = 4
    case cash = 5
}

// MARK: - Inventory Item

/// An item in a player's inventory.
public struct InventoryItem: Codable, Equatable, Hashable, Sendable {

    /// Unique identifier for this item instance
    public let id: UUID

    /// Item template ID
    public let itemId: UInt32

    /// Current slot in the inventory bag
    public var slot: Int8

    /// Quantity for stackable items (1 for equipment)
    public var quantity: UInt16

    /// For equipment, contains additional stats
    public var equip: EquipData?

    public init(
        id: UUID = UUID(),
        itemId: UInt32,
        slot: Int8,
        quantity: UInt16 = 1,
        equip: EquipData? = nil
    ) {
        self.id = id
        self.itemId = itemId
        self.slot = slot
        self.quantity = quantity
        self.equip = equip
    }
}

// MARK: - Equip Data

/// Stats and properties for equippable items.
public struct EquipData: Codable, Equatable, Hashable, Sendable {

    /// Slot position this equipment goes in (negative for equipped)
    public var slot: Int8

    // Stats
    public var str: UInt16
    public var dex: UInt16
    public var int: UInt16
    public var luk: UInt16
    public var hp: UInt16
    public var mp: UInt16
    public var weaponAttack: UInt16
    public var magicAttack: UInt16
    public var weaponDefense: UInt16
    public var magicDefense: UInt16
    public var accuracy: UInt16
    public var avoid: UInt16
    public var speed: UInt16
    public var jump: UInt16

    // Upgrade slots
    public var slots: Int8
    public var level: UInt8      // Upgrade level
    public var grade: String?    // Potential grade (rare, epic, legendary, etc.)

    // Owner and expiration
    public var owner: String?
    public var expiration: Date?

    public init(
        slot: Int8,
        str: UInt16 = 0,
        dex: UInt16 = 0,
        int: UInt16 = 0,
        luk: UInt16 = 0,
        hp: UInt16 = 0,
        mp: UInt16 = 0,
        weaponAttack: UInt16 = 0,
        magicAttack: UInt16 = 0,
        weaponDefense: UInt16 = 0,
        magicDefense: UInt16 = 0,
        accuracy: UInt16 = 0,
        avoid: UInt16 = 0,
        speed: UInt16 = 0,
        jump: UInt16 = 0,
        slots: Int8 = 7,
        level: UInt8 = 0,
        grade: String? = nil,
        owner: String? = nil,
        expiration: Date? = nil
    ) {
        self.slot = slot
        self.str = str
        self.dex = dex
        self.int = int
        self.luk = luk
        self.hp = hp
        self.mp = mp
        self.weaponAttack = weaponAttack
        self.magicAttack = magicAttack
        self.weaponDefense = weaponDefense
        self.magicDefense = magicDefense
        self.accuracy = accuracy
        self.avoid = avoid
        self.speed = speed
        self.jump = jump
        self.slots = slots
        self.level = level
        self.grade = grade
        self.owner = owner
        self.expiration = expiration
    }
}

// MARK: - Inventory Helpers

public extension Inventory {

    /// Get the bag for a given inventory type
    subscript(type: InventoryType) -> [Int8: InventoryItem] {
        get {
            switch type {
            case .equip: return equip
            case .use: return use
            case .setup: return setup
            case .etc: return etc
            case .cash: return cash
            }
        }
        set {
            switch type {
            case .equip: equip = newValue
            case .use: use = newValue
            case .setup: setup = newValue
            case .etc: etc = newValue
            case .cash: cash = newValue
            }
        }
    }

    /// Find an empty slot in the specified inventory bag
    func findEmptySlot(in type: InventoryType, maxSlots: Int8 = 100) -> Int8? {
        let bag = self[type]
        for slot in 1...maxSlots {
            if bag[slot] == nil {
                return slot
            }
        }
        return nil
    }

    /// Count total quantity of an item across all stacks
    func countItem(_ itemId: UInt32, in type: InventoryType) -> UInt16 {
        return self[type].values.reduce(0) { total, item in
            item.itemId == itemId ? total + item.quantity : total
        }
    }
}

// MARK: - Inventory Item Helpers

public extension InventoryItem {

    /// Check if this item is equipment
    var isEquipment: Bool {
        return equip != nil
    }

    /// Check if this item is stackable
    var isStackable: Bool {
        // Equipment is never stackable
        guard equip == nil else { return false }

        // Most consumables, setup, etc, and cash items are stackable
        return true
    }
}

// MARK: - Equip Slot Constants

public extension Int8 {

    // Equipped slots (negative)
    static let equipHat: Int8 = -1
    static let equipFace: Int8 = -2
    static let equipEye: Int8 = -3
    static let equipEar: Int8 = -4
    static let equipTop: Int8 = -5
    static let equipBottom: Int8 = -6
    static let equipShoes: Int8 = -7
    static let equipGloves: Int8 = -8
    static let equipCape: Int8 = -9
    static let equipShield: Int8 = -10
    static let equipWeapon: Int8 = -11
    static let equipRing1: Int8 = -12
    static let equipRing2: Int8 = -13
    static let equipRing3: Int8 = -14
    static let equipRing4: Int8 = -15
    static let equipPocket: Int8 = -16
    static let equipPetEquip: Int8 = -17

    // Inventory bag slots (positive, 1-based)
    static let inventoryStart: Int8 = 1
    static let inventoryEnd: Int8 = 100
}
