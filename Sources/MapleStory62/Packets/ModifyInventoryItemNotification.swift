//
//  ModifyInventoryItemNotification.swift
//
//

import Foundation

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
    public let item: InventoryItem?
    public let quantity: UInt16?

    public init(mode: Mode, inventoryType: InventoryType, slot: Int8, item: InventoryItem? = nil, quantity: UInt16? = nil) {
        self.mode = mode
        self.inventoryType = inventoryType
        self.slot = slot
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
        // In the protocol, move operations send the old slot as the value
        // We'll encode this properly when the packet encoding is implemented
        var movedItem = item
        movedItem.slot = toSlot
        return ModifyInventoryItemNotification(
            mode: .move,
            inventoryType: inventoryType,
            slot: toSlot,
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

