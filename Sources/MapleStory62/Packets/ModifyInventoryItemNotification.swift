//
//  ModifyInventoryItemNotification.swift
//
//

import Foundation
import MapleStory

public enum ModifyInventoryItemNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .modifyInventoryItem }

    /// Add a new item to inventory
    case add(item: InventoryItem, inventoryType: InventoryType)
    
    /// Update an existing item's quantity
    case update(item: InventoryItem, inventoryType: InventoryType, quantity: UInt16)
    
    /// Move an item from one slot to another
    case move(item: InventoryItem, fromSlot: Int8, toSlot: Int8, inventoryType: InventoryType)
    
    /// Remove an item from inventory
    case remove(inventoryType: InventoryType, slot: Int8, itemId: UInt32)
}

extension ModifyInventoryItemNotification: MapleStoryEncodable {
    
    public func encode(to encoder: Encoder) throws {
        // The MapleStoryEncoder has special handling for MapleStoryEncodable types
        // It will check the protocol and call encode(to: MapleStoryEncodingContainer)
        // This method is only here to satisfy the Encodable protocol requirement
        // and should not be called during normal packet encoding
        fatalError("This should not be called. Use encode(to: MapleStoryEncodingContainer)")
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .add:
            try encodeAdd(to: container)
        case .update:
            try encodeUpdate(to: container)
        case .move:
            try encodeMove(to: container)
        case .remove:
            try encodeRemove(to: container)
        }
    }

    /// Encode add mode: fromDrop + 0x01 0x00 + inventoryType + slot + itemInfo
    private func encodeAdd(to container: MapleStoryEncodingContainer) throws {
        // fromDrop (assume false for now)
        try container.encode(UInt8(0))
        // operation mode bytes: 0x01 0x00
        try container.encode(UInt8(1))
        try container.encode(UInt8(0))
        
        // Extract item and inventory type
        guard case let .add(item, inventoryType) = self else {
            fatalError("Invalid state: encodeAdd called on non-add case")
        }
        
        // inventory type
        try container.encode(inventoryType.rawValue)
        // slot
        try container.encode(item.slot)
        // item info
        try encodeItemInfo(item, to: container)
    }
    
    /// Encode update mode: fromDrop + 0x01 0x01 + inventoryType + slot + 0x00 + quantity
    private func encodeUpdate(to container: MapleStoryEncodingContainer) throws {
        // fromDrop (assume false for now)
        try container.encode(UInt8(0))
        // operation mode bytes: 0x01 0x01
        try container.encode(UInt8(1))
        try container.encode(UInt8(1))
        
        // Extract item, inventory type, and quantity
        guard case let .update(item, inventoryType, quantity) = self else {
            fatalError("Invalid state: encodeUpdate called on non-update case")
        }
        
        // inventory type
        try container.encode(inventoryType.rawValue)
        // slot
        try container.encode(item.slot)
        // unknown byte
        try container.encode(UInt8(0))
        // quantity
        try container.encode(quantity)
    }
    
    /// Encode move mode: 0x01 0x01 0x02 + inventoryType + src(short) + dst(short)
    private func encodeMove(to container: MapleStoryEncodingContainer) throws {
        // operation mode bytes: 0x01 0x01 0x02
        try container.encode(UInt8(1))
        try container.encode(UInt8(1))
        try container.encode(UInt8(2))
        
        // Extract item, fromSlot, toSlot, and inventory type
        guard case let .move(_, fromSlot, toSlot, inventoryType) = self else {
            fatalError("Invalid state: encodeMove called on non-move case")
        }
        
        // inventory type
        try container.encode(inventoryType.rawValue)
        // source slot (as short)
        try container.encode(Int16(fromSlot))
        // destination slot (as short)
        try container.encode(Int16(toSlot))
    }
    
    /// Encode remove mode: fromDrop + 0x01 0x03 + inventoryType + slot(short)
    private func encodeRemove(to container: MapleStoryEncodingContainer) throws {
        // fromDrop (assume false for now)
        try container.encode(UInt8(0))
        // operation mode bytes: 0x01 0x03
        try container.encode(UInt8(1))
        try container.encode(UInt8(3))
        
        // Extract inventory type and slot
        guard case let .remove(inventoryType, slot, _) = self else {
            fatalError("Invalid state: encodeRemove called on non-remove case")
        }
        
        // inventory type
        try container.encode(inventoryType.rawValue)
        // slot (as short)
        try container.encode(Int16(slot))
    }
    
    /// Encode item info (simplified version for non-equipment, non-pet items)
    private func encodeItemInfo(_ item: InventoryItem, to container: MapleStoryEncodingContainer) throws {
        // Position
        try container.encode(item.slot)
        
        // Item type (1 = equip, 2 = use, 3 = setup, 4 = etc, 5 = cash)
        let itemType: UInt8
        if item.equip != nil {
            itemType = 1
        } else {
            // Get inventory type from the current enum case
            switch self {
            case let .add(_, inventoryType):
                itemType = inventoryType.rawValue
            case let .update(_, inventoryType, _):
                itemType = inventoryType.rawValue
            default:
                itemType = 2 // Default to use
            }
        }
        try container.encode(itemType)
        
        // Item ID
        try container.encode(item.itemId, isLittleEndian: true)
        
        // For equipment, encode stats
        if let equipData = item.equip {
            try encodeEquipData(equipData, to: container)
        }
    }
    
    /// Encode equipment data
    private func encodeEquipData(_ equip: EquipData, to container: MapleStoryEncodingContainer) throws {
        try container.encode(Int16(equip.slots))
        try container.encode(UInt8(0)) // ?
        try container.encode(equip.str)
        try container.encode(equip.dex)
        try container.encode(equip.int)
        try container.encode(equip.luk)
        try container.encode(equip.hp)
        try container.encode(equip.mp)
        try container.encode(equip.weaponAttack)
        try container.encode(equip.magicAttack)
        try container.encode(equip.weaponDefense)
        try container.encode(equip.magicDefense)
        try container.encode(equip.accuracy)
        try container.encode(equip.avoid)
        try container.encode(equip.speed)
        try container.encode(equip.jump)
        try container.encode(equip.owner ?? "", fixedLength: 13)
        try container.encode(UInt8(0)) // ?
    }
}