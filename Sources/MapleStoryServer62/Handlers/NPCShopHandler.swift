//
//  NPCShopHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct NPCShopHandler: PacketHandler {

    public typealias Packet = MapleStory62.NPCShopRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Get current shop NPC from conversation state
        guard let shopNPCID = await NPCConversationRegistry.shared.getNPC(for: connection.address) else {
            return // Not talking to a shop NPC
        }

        guard let shop = await ShopDataCache.shared.shop(npcID: shopNPCID) else {
            return // Shop not found
        }

        let manipulator = InventoryManipulator()

        switch packet.mode {
        case 0: // Buy
            guard let itemID = packet.itemID,
                  let slot = packet.slot,
                  let quantity = packet.quantity else {
                return
            }
            try await handleBuy(
                itemID: itemID,
                slot: slot,
                quantity: quantity,
                shop: shop,
                character: &character,
                manipulator: manipulator,
                connection: connection
            )

        case 1: // Sell
            guard let itemID = packet.itemID,
                  let slot = packet.slot,
                  let quantity = packet.quantity else {
                return
            }
            try await handleSell(
                itemID: itemID,
                slot: slot,
                quantity: quantity,
                character: &character,
                manipulator: manipulator,
                connection: connection
            )

        case 2: // Recharge
            guard let slot = packet.slot else {
                return
            }
            try await handleRecharge(
                slot: slot,
                shop: shop,
                character: &character,
                manipulator: manipulator,
                connection: connection
            )

        default:
            return // Invalid mode
        }

        // Save character
        try await connection.database.insert(character)
    }

    // MARK: - Buy

    private func handleBuy<Socket: MapleStorySocket, Database: ModelStorage>(
        itemID: UInt32,
        slot: Int16,
        quantity: Int16,
        shop: NPCShop,
        character: inout Character,
        manipulator: InventoryManipulator,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Find item in shop
        guard let shopItem = shop.items.first(where: { $0.itemID == itemID }) else {
            return // Item not sold by shop
        }

        // Check stock
        if shopItem.stock == 0 {
            // Infinite stock, ok
        } else if shopItem.stock < 0 {
            return // Out of stock
        }

        // Calculate total cost
        let totalCost = shopItem.price * UInt32(quantity)

        // Check if character has enough mesos
        guard character.meso >= totalCost else {
            return // Not enough mesos
        }

        // Check inventory space
        guard try await manipulator.checkSpace(
            itemID,
            quantity: UInt16(quantity),
            for: character
        ) else {
            return // No inventory space
        }

        // Deduct mesos
        character.meso = character.meso - totalCost

        // Add item to inventory
        try await manipulator.addFromDrop(
            itemID,
            quantity: UInt16(quantity),
            to: character
        )

        // Send confirmation to client
        try await connection.send(ConfirmShopTransactionNotification(
            mode: 0, // buy
            slot: slot,
            itemID: itemID,
            quantity: quantity
        ))
    }

    // MARK: - Sell

    private func handleSell<Socket: MapleStorySocket, Database: ModelStorage>(
        itemID: UInt32,
        slot: Int16,
        quantity: Int16,
        character: inout Character,
        manipulator: InventoryManipulator,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let inventory = await character.getInventory()

        // Determine inventory type from item ID
        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemID) else {
            return
        }

        // Check if item exists in slot
        guard let item = inventory[inventoryType][Int8(slot)] else {
            return
        }

        // Verify item ID matches
        guard item.itemId == itemID else {
            return
        }

        // Calculate sell price (typically 1/10th of buy price)
        let basePrice = await ItemDataCache.shared.price(for: itemID)
        let sellPrice = UInt32(basePrice / 10)

        // Remove item from inventory
        let removed = try await manipulator.removeById(
            itemID,
            quantity: UInt16(quantity),
            from: character
        )

        guard removed else {
            return
        }

        // Add mesos
        character.meso = character.meso + sellPrice

        // Send confirmation to client
        try await connection.send(ConfirmShopTransactionNotification(
            mode: 1, // sell
            slot: slot,
            itemID: itemID,
            quantity: quantity
        ))
    }

    // MARK: - Recharge

    private func handleRecharge<Socket: MapleStorySocket, Database: ModelStorage>(
        slot: Int16,
        shop: NPCShop,
        character: inout Character,
        manipulator: InventoryManipulator,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let inventory = await character.getInventory()

        // Recharge items are in USE inventory
        let inventoryType = InventoryType.use

        // Check if item exists in slot
        guard let item = inventory[inventoryType][Int8(slot)] else {
            return
        }

        // Check if this is a rechargeable item
        guard await ShopDataCache.shared.isRechargeItem(itemID: item.itemId, npcID: shop.npcID) else {
            return
        }

        // Calculate recharge cost
        let maxQuantity = Int16(await ItemDataCache.shared.maxStackSize(for: item.itemId))
        let neededQuantity = maxQuantity - Int16(item.quantity)
        guard neededQuantity > 0 else {
            return // Already full
        }

        let basePrice = await ShopDataCache.shared.price(itemID: item.itemId, npcID: shop.npcID) ?? 1
        let rechargeCost = UInt32(neededQuantity) * (basePrice / UInt32(maxQuantity))

        // Check if character has enough mesos
        guard character.meso >= rechargeCost else {
            return // Not enough mesos
        }

        // Deduct mesos
        character.meso = character.meso - rechargeCost

        // Update item quantity
        var updatedInventory = await character.getInventory()
        let useInventory = updatedInventory[.use]
        if var item = useInventory[Int8(slot)] {
            item.quantity = UInt16(maxQuantity)
            updatedInventory[.use][Int8(slot)] = item
        }
        await character.setInventory(updatedInventory)

        // Send confirmation to client
        try await connection.send(ConfirmShopTransactionNotification(
            mode: 2, // recharge
            slot: slot,
            itemID: item.itemId,
            quantity: maxQuantity
        ))
    }
}
