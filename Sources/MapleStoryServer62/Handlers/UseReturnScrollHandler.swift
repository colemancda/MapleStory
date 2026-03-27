//
//  UseReturnScrollHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles return scroll usage (teleporting to saved locations).
///
/// Return scrolls are consumable items that teleport the player to a
/// previously saved location. Each scroll can only be used once.
///
/// # Return Scroll Types
///
/// - **Nearest Town**: Teleport to nearest town
/// - **Specific Map**: Teleport to specific saved map
/// - **Dungeon Exit**: Escape from dungeon
///
/// # Flow
///
/// 1. Player uses return scroll item
/// 2. Server validates item exists
/// 3. Server consumes item from inventory
/// 4. Server looks up destination for scroll type
/// 5. Server warps player to destination
///
public struct UseReturnScrollHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseReturnScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get inventory
        let inventory = await character.getInventory()

        // Get return scroll from USE inventory
        guard let scrollItem = inventory[.use][Int8(packet.slot)] else {
            return // Item doesn't exist
        }

        // Validate it's the correct item
        guard scrollItem.itemId == packet.itemID else {
            return // Item mismatch
        }

        // Validate it's a return scroll (item ID 2030xxx)
        guard isReturnScroll(packet.itemID) else {
            return // Not a return scroll
        }

        // Determine return destination based on current map
        let returnMap = getReturnTown(for: character.currentMap)

        // Consume the scroll
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        // Save character
        try await connection.database.insert(character)

        // Warp to return town
        try await connection.warp(to: returnMap, spawn: 0)

        // Enable actions
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private Helpers

    /// Check if item is a return scroll
    private func isReturnScroll(_ itemID: UInt32) -> Bool {
        // Return scrolls are in the 2030xxx range
        return itemID >= 2_030_000 && itemID < 2_040_000
    }

    // MARK: - Private Helpers

    /// Get return town map for a given map
    private func getReturnTown(for mapID: Map.ID) -> Map.ID {
        // Simplified return town mapping
        // In a full implementation, this would be a comprehensive lookup table

        switch mapID.rawValue {
        // Victoria Island towns
        case 100000000...200000000:
            return Map.ID(rawValue: 100000000) // Henesys

        // Ellinia maps -> return to Ellinia
        case 101000000, 101000001, 101000002, 101000003, 101000004:
            return Map.ID(rawValue: 101000000) // Ellinia

        // Perion maps -> return to Perion
        case 102000000, 102000001, 102000003, 102000005:
            return Map.ID(rawValue: 102000000) // Perion

        // Kerning City maps -> return to Kerning
        case 103000000, 103000001, 103000004, 103000005:
            return Map.ID(rawValue: 103000000) // Kerning

        // Lith Harbor maps -> return to Lith Harbor
        case 104000000, 104000001:
            return Map.ID(rawValue: 104000000) // Lith Harbor

        // Default: return to Henesys
        default:
            return Map.ID(rawValue: 100000000) // Henesys
        }
    }
}
