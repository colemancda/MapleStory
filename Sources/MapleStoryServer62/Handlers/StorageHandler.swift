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

/// Handles account storage (bank) operations.
///
/// Account storage is a shared bank that allows players to transfer
/// items and mesos between their characters on the same world.
/// Storage is accessed via NPC (e.g., Mr. Lee in Henesys).
///
/// # Storage Operations
///
/// | Mode | Operation | Description |
/// |------|-----------|-------------|
/// | 4 | Withdraw | Take item from storage |
/// | 5 | Deposit | Store item in storage (costs 100 mesos) |
/// | 7 | Meso | Deposit/withdraw mesos |
/// | 8 | Close | Close storage UI |
///
/// # Storage Limits
///
/// - **Slots**: Default 16 slots, expandable with NX
/// - **Items**: Up to 1 item per slot
/// - **Mesos**: Can store mesos (with overflow protection)
///
/// # Cross-Character Access
///
/// All characters on the same account and world share the same storage,
/// making it useful for transferring items between characters.
public struct StorageHandler: PacketHandler {

    public typealias Packet = MapleStory62.StorageRequest

    /// Fee for depositing items into storage
    public static let depositFee: UInt32 = 100

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

        case 8: // Close
            await handleClose(userID: userID)

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
        let storage = await StorageRegistry.shared.storage(userID: userID)
        
        // Convert UI slot to actual storage slot based on inventory type
        guard let actualSlot = await StorageRegistry.shared.getSlot(
            inventoryType: InventoryType(rawValue: inventoryType) ?? .etc,
            uiSlot: Int8(slot),
            userID: userID
        ) else {
            return // Invalid slot
        }
        
        // Withdraw item from storage
        guard let item = await StorageRegistry.shared.withdrawItem(
            slot: actualSlot,
            from: userID
        ) else {
            return // No item at slot
        }

        let manipulator = InventoryManipulator()

        // Check inventory space
        guard try await manipulator.checkSpace(
            item.itemId,
            quantity: item.quantity,
            for: character
        ) else {
            // Return item to storage
            _ = await StorageRegistry.shared.depositItem(item, to: userID)
            // Send "inventory full" notice
            try await connection.send(ServerMessageNotification.alert("Your inventory is full"))
            return
        }

        // Add to character inventory
        try await manipulator.addFromDrop(
            item.itemId,
            quantity: item.quantity,
            to: character
        )

        // Send storage update notification (taken out)
        try await sendTakenOutNotification(
            inventoryType: InventoryType(rawValue: inventoryType) ?? .etc,
            userID: userID,
            connection: connection
        )
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
        guard quantity >= 1 else {
            return // Invalid quantity
        }
        
        let storage = await StorageRegistry.shared.storage(userID: userID)
        
        guard !storage.isFull else {
            try await connection.send(StorageFullNotification())
            return
        }
        
        // Check if player has enough mesos for deposit fee
        guard character.meso >= Self.depositFee else {
            try await connection.send(ServerMessageNotification.alert("You don't have enough mesos to store the item"))
            return
        }
        
        let inventory = await character.getInventory()

        // Determine inventory type from item ID
        guard let inventoryType = await ItemDataCache.shared.inventoryType(for: itemID) else {
            return
        }

        // Get item from character inventory
        guard let item = inventory[inventoryType][Int8(slot)] else {
            return
        }

        // Verify item ID matches 
        guard item.itemId == itemID else {
            return // Item ID mismatch - potential exploit
        }
        
        // Verify quantity
        guard item.quantity >= UInt16(quantity) else {
            return // Quantity mismatch - potential exploit
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
        
        // Deduct deposit fee 
        character.meso = character.meso - Self.depositFee

        // Prepare item for storage with correct quantity
        var storageItem = item
        storageItem.quantity = UInt16(quantity)

        // Deposit into storage
        guard let _ = await StorageRegistry.shared.depositItem(
            storageItem,
            to: userID
        ) else {
            // Return item to character (no storage space) - should not happen since we checked
            try await manipulator.addFromDrop(itemID, quantity: UInt16(quantity), to: character)
            character.meso = character.meso + Self.depositFee // Refund fee
            return
        }

        // Send storage update notification (stored)
        try await sendStoredNotification(
            inventoryType: inventoryType,
            userID: userID,
            connection: connection
        )
    }

    // MARK: - Meso

    private func handleMeso<Socket: MapleStorySocket, Database: ModelStorage>(
        meso: UInt32,
        userID: User.ID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let mesoSigned = Int32(bitPattern: meso)
        let storage = await StorageRegistry.shared.storage(userID: userID)
        let storageMesos = Int32(bitPattern: storage.mesos)
        let playerMesos = Int32(bitPattern: character.meso)
        
        var transferAmount = mesoSigned
        
        // if ((meso > 0 && storageMesos >= meso) || (meso < 0 && playerMesos >= -meso))
        if mesoSigned > 0 {
            // Withdrawing from storage
            guard storageMesos >= mesoSigned else {
                return // Not enough mesos in storage
            }
            
            // Overflow protection
            if playerMesos + mesoSigned < 0 {
                // Would overflow - cap at max
                transferAmount = Int32.max - playerMesos
                guard transferAmount <= storageMesos else {
                    return // Should never happen
                }
            }
            
            // Update storage and character
            let _ = await StorageRegistry.shared.removeMesos(UInt32(bitPattern: transferAmount), from: userID)
            character.meso = UInt32(bitPattern: playerMesos + transferAmount)
            
        } else if mesoSigned < 0 {
            // Depositing to storage (negative value means deposit)
            let depositAmount = -mesoSigned
            guard playerMesos >= depositAmount else {
                return // Not enough mesos on character
            }
            
            // Overflow protection 
            if storageMesos + depositAmount < 0 {
                // Would overflow - cap at max
                transferAmount = -(Int32.max - storageMesos)
                let cappedDeposit = -transferAmount
                guard cappedDeposit <= playerMesos else {
                    return // Should never happen
                }
            }
            
            // Update storage and character
            await StorageRegistry.shared.addMesos(UInt32(bitPattern: -transferAmount), to: userID)
            character.meso = UInt32(bitPattern: playerMesos + transferAmount) // transferAmount is negative
            
        } else {
            return // meso == 0, nothing to do
        }

        // Send meso update notification
        try await sendMesoNotification(userID: userID, connection: connection)
    }

    // MARK: - Close

    private func handleClose(userID: User.ID) async {
        await StorageRegistry.shared.close(userID: userID)
    }

    // MARK: - Notifications

    private func sendStoredNotification<Socket: MapleStorySocket, Database: ModelStorage>(
        inventoryType: InventoryType,
        userID: User.ID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let storage = await StorageRegistry.shared.storage(userID: userID)
        let items = await StorageRegistry.shared.getItemsByType(inventoryType, userID: userID)
        
        try await connection.send(StorageStoredNotification(
            slots: storage.maxSlots,
            inventoryType: inventoryType,
            items: items.map { StorageItemEntry(slot: $0.slot, itemID: $0.itemId, quantity: $0.quantity) }
        ))
    }

    private func sendTakenOutNotification<Socket: MapleStorySocket, Database: ModelStorage>(
        inventoryType: InventoryType,
        userID: User.ID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let storage = await StorageRegistry.shared.storage(userID: userID)
        let items = await StorageRegistry.shared.getItemsByType(inventoryType, userID: userID)
        
        try await connection.send(StorageTakenOutNotification(
            slots: storage.maxSlots,
            inventoryType: inventoryType,
            items: items.map { StorageItemEntry(slot: $0.slot, itemID: $0.itemId, quantity: $0.quantity) }
        ))
    }

    private func sendMesoNotification<Socket: MapleStorySocket, Database: ModelStorage>(
        userID: User.ID,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let storage = await StorageRegistry.shared.storage(userID: userID)
        
        try await connection.send(StorageMesoNotification(
            slots: storage.maxSlots,
            mesos: storage.mesos
        ))
    }
}

// MARK: - Additional Notifications

/// Notification sent when storage is full
public struct StorageFullNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    public static var opcode: ServerOpcode { .storageFull }
    public init() {}
}

/// Notification sent when item is stored
public struct StorageStoredNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    public static var opcode: ServerOpcode { .storageStored }
    public let slots: UInt8
    public let inventoryType: InventoryType
    public let items: [StorageItemEntry]
}

/// Notification sent when item is taken out
public struct StorageTakenOutNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    public static var opcode: ServerOpcode { .storageTakenOut }
    public let slots: UInt8
    public let inventoryType: InventoryType
    public let items: [StorageItemEntry]
}

/// Notification sent when mesos are updated
public struct StorageMesoNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    public static var opcode: ServerOpcode { .storageMeso }
    public let slots: UInt8
    public let mesos: UInt32
}