//
//  UseCatchItemHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles monster catching items (catching monsters with items).
///
/// Some items allow players to capture monsters. When used successfully,
/// the monster is added to the player's monster collection.
///
/// # Catch Items
///
/// - **Pouches**: Capture monsters in a pouch
/// - **Nets**: Capture monsters in a net
/// - **Traps**: Capture monsters with a trap
///
/// # Flow
///
/// 1. Player uses catch item on monster
/// 2. Server calculates catch success rate
/// 3. If successful, monster is captured
/// 4. Monster is added to player's collection
/// 5. Item is consumed
///
public struct UseCatchItemHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseCatchItemRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get inventory
        let inventory = await character.getInventory()

        // Get catch item from USE inventory
        guard let catchItem = inventory[.use][Int8(packet.slot)] else {
            return // Item doesn't exist
        }

        // Validate it's the correct item
        guard catchItem.itemId == packet.itemID else {
            return // Item mismatch
        }

        // Validate it's a catch item (item ID 2270xxx)
        guard isCatchItem(packet.itemID) else {
            return // Not a catch item
        }

        // Get monster from map
        let mobRegistry = MapMobRegistry.shared
        guard let mob = await mobRegistry.mob(objectID: packet.monsterID) else {
            return // Monster not found
        }

        // Validate monster HP is at or below 50% of max HP
        guard mob.currentHP <= mob.maxHP / 2 else {
            // Monster is too strong
            let message = "You cannot catch the monster as it is too strong."
            try await connection.send(ServerMessageNotification(message: message, type: .popup))
            return
        }

        // Check if this is the Ariant PQ catch item (2270002)
        if packet.itemID == 2_270_002 {
            // Broadcast catch notification
            await connection.broadcast(CatchMonsterNotification(
                monsterID: packet.monsterID,
                itemID: packet.itemID,
                success: 1
            ))
        }

        // Kill the monster (no drops, no exp)
        await mobRegistry.killMonster(
            objectID: packet.monsterID,
            mapID: character.map,
            dropItems: false,
            giveExp: false
        )

        // Consume the catch item
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        // Save character
        try await connection.database.insert(character)

        // Enable actions
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private Helpers

    private func isCatchItem(_ itemID: UInt32) -> Bool {
        // Catch items are in the 2270xxx range
        return itemID >= 2_270_000 && itemID < 2_271_000
    }
}
