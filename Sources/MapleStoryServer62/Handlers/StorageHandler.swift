//
//  StorageHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct StorageHandler: PacketHandler {

    public typealias Packet = MapleStory62.StorageRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Get user ID from character
        let userID = character.user

        switch packet.mode {
        case 4: // Withdraw
            guard let inventoryType = packet.inventoryType,
                  let slot = packet.slot else {
                return
            }
            try await handleWithdraw(
                inventoryType: inventoryType,
                slot: slot,
                userID: userID,
                character: &character,
                connection: connection
            )

        case 5: // Deposit
            guard let slot = packet.slot,
                  let itemID = packet.itemID,
                  let quantity = packet.quantity else {
                return
            }
            try await handleDeposit(
                slot: slot,
                itemID: itemID,
                quantity: quantity,
                userID: userID,
                character: &character,
                connection: connection
            )

        case 7: // Meso
            guard let meso = packet.meso else {
                return
            }
            try await handleMeso(
                meso: meso,
                userID: userID,
                character: &character,
                connection: connection
            )

        default:
            return // Invalid mode
        }

        // Save character
        try await connection.database.insert(character)
    }

    // MARK: - Withdraw

    private func handleWithdraw<Socket: MapleStorySocket, Database: ModelStorage>(
        inventoryType: UInt8,
        slot: UInt8,
        userID: User.ID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Withdraw item from storage
        guard let item = await StorageRegistry.shared.withdrawItem(
            slot: Int8(slot),
            from: userID
        ) else {
            return // No item at slot
        }

        let manipulator = InventoryManipulator()
        let invType = InventoryType(rawValue: inventoryType) ?? .etc

        // Check inventory space
        guard try await manipulator.checkSpace(
            item.itemId,
            quantity: item.quantity,
            for: character
        ) else {
            // Return item to storage
            _ = await StorageRegistry.shared.depositItem(item, to: userID)
            return
        }

        // Add to character inventory
        try await manipulator.addFromDrop(
            item.itemId,
            quantity: item.quantity,
            to: character
        )

        // Send storage update notification
        try await sendStorageUpdate(userID: userID, connection: connection)
    }

    // MARK: - Deposit

    private func handleDeposit<Socket: MapleStorySocket, Database: ModelStorage>(
        slot: UInt8,
        itemID: UInt32,
        quantity: Int16,
        userID: User.ID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let inventory = await character.getInventory()

        // Determine inventory type from item ID
        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemID) else {
            return
        }

        // Get item from character inventory
        guard let item = inventory[inventoryType][Int8(slot)] else {
            return
        }

        // Verify item ID
        guard item.itemId == itemID else {
            return
        }

        // Remove from character inventory
        let manipulator = InventoryManipulator()
        let removed = try await manipulator.removeById(
            itemID,
            quantity: UInt16(quantity),
            from: character
        )

        guard removed else {
            return
        }

        // Deposit into storage
        guard let storageSlot = await StorageRegistry.shared.depositItem(
            item,
            to: userID
        ) else {
            // Return item to character (no storage space)
            try await manipulator.addFromDrop(itemID, quantity: UInt16(quantity), to: character)
            return
        }

        // Send storage update notification
        try await sendStorageUpdate(userID: userID, connection: connection)
    }

    // MARK: - Meso

    private func handleMeso<Socket: MapleStorySocket, Database: ModelStorage>(
        meso: UInt32,
        userID: User.ID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        if meso > 0 {
            // Withdraw mesos from storage
            let success = await StorageRegistry.shared.removeMesos(meso, from: userID)
            guard success else {
                return // Not enough mesos in storage
            }
            character.meso = character.meso + meso
        } else {
            // Deposit mesos to storage
            let amount = abs(Int32(bitPattern: meso))
            guard character.meso >= UInt32(amount) else {
                return // Not enough mesos
            }
            character.meso = character.meso - UInt32(amount)
            await StorageRegistry.shared.addMesos(UInt32(amount), to: userID)
        }

        // Send storage update notification
        try await sendStorageUpdate(userID: userID, connection: connection)
    }

    // MARK: - Helper

    private func sendStorageUpdate<Socket: MapleStorySocket, Database: ModelStorage>(
        userID: User.ID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let storage = await StorageRegistry.shared.storage(userID: userID)

        // Convert storage items to notification format
        var items: [StorageItemEntry] = []
        for (slot, item) in storage.items {
            items.append(StorageItemEntry(
                slot: slot,
                itemID: item.itemId,
                quantity: item.quantity
            ))
        }

        // Send storage notification
        try await connection.send(OpenStorageNotification(
            npcID: 0, // TODO: Track actual storage NPC ID
            mesos: storage.mesos,
            slots: storage.slots,
            maxSlots: storage.maxSlots,
            items: items
        ))
    }
}
