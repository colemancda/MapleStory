//
//  ModifyInventoryItemNotification.swift
//
//

import Foundation
import MapleStory

public struct ModifyInventoryItemNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .modifyInventoryItem }

    public enum Mode: UInt8, Sendable {
        case add = 0
        case update = 1
        case move = 2
        case remove = 3
    }

    public let mode: Mode
    public let inventoryType: InventoryType
    public let slot: Int8
    public let fromSlot: Int8?
    public let item: InventoryItem?
    public let quantity: UInt16?

    public init(mode: Mode, inventoryType: InventoryType, slot: Int8, fromSlot: Int8? = nil, item: InventoryItem? = nil, quantity: UInt16? = nil) {
        self.mode = mode
        self.inventoryType = inventoryType
        self.slot = slot
        self.fromSlot = fromSlot
        self.item = item
        self.quantity = quantity
    }

    /// Create a move notification (item moved from one slot to another)
    public static func move(
        item: InventoryItem,
        fromSlot: Int8,
        toSlot: Int8,
        inventoryType: InventoryType
    ) -> ModifyInventoryItemNotification {
        var movedItem = item
        movedItem.slot = toSlot
        return ModifyInventoryItemNotification(
            mode: .move,
            inventoryType: inventoryType,
            slot: toSlot,
            fromSlot: fromSlot,
            item: movedItem,
            quantity: nil
        )
    }

    /// Create an add notification (new item added)
    public static func add(
        item: InventoryItem,
        inventoryType: InventoryType
    ) -> ModifyInventoryItemNotification {
        return ModifyInventoryItemNotification(
            mode: .add,
            inventoryType: inventoryType,
            slot: item.slot,
            item: item,
            quantity: item.quantity
        )
    }

    /// Create an update notification (quantity changed)
    public static func update(
        item: InventoryItem,
        inventoryType: InventoryType,
        quantity: UInt16
    ) -> ModifyInventoryItemNotification {
        return ModifyInventoryItemNotification(
            mode: .update,
            inventoryType: inventoryType,
            slot: item.slot,
            item: item,
            quantity: quantity
        )
    }

    /// Create a remove notification (item removed)
    public static func remove(
        inventoryType: InventoryType,
        slot: Int8,
        itemId: UInt32
    ) -> ModifyInventoryItemNotification {
        let item = InventoryItem(id: UUID(), itemId: itemId, slot: slot, quantity: 0)
        return ModifyInventoryItemNotification(
            mode: .remove,
            inventoryType: inventoryType,
            slot: slot,
            item: item,
            quantity: nil
        )
    }
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
        switch mode {
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
        // inventory type
        try container.encode(inventoryType.rawValue)
        // slot
        try container.encode(slot)
        // item info
        guard let item = item else {
            throw EncodingError.invalidValue(
                self,
                .init(codingPath: container.codingPath, debugDescription: "Add mode requires item")
            )
        }
        try encodeItemInfo(item, to: container)
    }
    
    /// Encode update mode: fromDrop + 0x01 0x01 + inventoryType + slot + 0x00 + quantity
    private func encodeUpdate(to container: MapleStoryEncodingContainer) throws {
        // fromDrop (assume false for now)
        try container.encode(UInt8(0))
        // operation mode bytes: 0x01 0x01
        try container.encode(UInt8(1))
        try container.encode(UInt8(1))
        // inventory type
        try container.encode(inventoryType.rawValue)
        // slot
        try container.encode(slot)
        // unknown byte
        try container.encode(UInt8(0))
        // quantity
        guard let quantity = quantity else {
            throw EncodingError.invalidValue(
                self,
                .init(codingPath: container.codingPath, debugDescription: "Update mode requires quantity")
            )
        }
        try container.encode(quantity)
    }
    
    /// Encode move mode: 0x01 0x01 0x02 + inventoryType + src(short) + dst(short)
    private func encodeMove(to container: MapleStoryEncodingContainer) throws {
        // operation mode bytes: 0x01 0x01 0x02
        try container.encode(UInt8(1))
        try container.encode(UInt8(1))
        try container.encode(UInt8(2))
        // inventory type
        try container.encode(inventoryType.rawValue)
        // source slot (as short)
        guard let fromSlot = fromSlot else {
            throw EncodingError.invalidValue(
                self,
                .init(codingPath: container.codingPath, debugDescription: "Move mode requires fromSlot")
            )
        }
        try container.encode(Int16(fromSlot))
        // destination slot (as short)
        try container.encode(Int16(slot))
    }
    
    /// Encode remove mode: fromDrop + 0x01 0x03 + inventoryType + slot(short)
    private func encodeRemove(to container: MapleStoryEncodingContainer) throws {
        // fromDrop (assume false for now)
        try container.encode(UInt8(0))
        // operation mode bytes: 0x01 0x03
        try container.encode(UInt8(1))
        try container.encode(UInt8(3))
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
            // Simple assumption based on inventory type
            itemType = inventoryType.rawValue
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
