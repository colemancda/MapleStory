//
//  ItemPickupHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles item pickup from ground drops.
///
/// # Drop System
///
/// Items can be dropped by:
/// - Monster drops
/// - Player dropping from inventory
/// - Meso drops
/// - Cash shop items
///
/// Drops appear on the ground and can be picked up by players.
///
/// # Pickup Rules
///
/// ## Ownership
/// - **Owned drops**: Only the player who dropped it can pick up
/// - **Free drops**: Anyone can pick up (after ownership expires)
/// - **Party drops**: Party members can pick up (if implemented)
///
/// ## Time Limit
/// - Drops expire after a set time (usually 2-3 minutes)
/// - Expired drops are automatically removed
/// - Client shows drop fading out before disappearing
///
/// ## Distance Check
/// - Player must be within 150 units (pixels) of drop
/// - Prevents picking up items from across the map
/// - Anti-cheat measure against vac hacking
///
/// # Inventory Validation
///
/// ## Meso Pickup (itemID == 0)
/// - No inventory space needed
/// - Mesos are added to meso count
/// - Can hold up to 2,147,483,647 mesos (UInt32 max)
///
/// ## Item Pickup
/// - Server checks for available inventory space
/// - Must have room in appropriate inventory type
/// - Items are added to first available slot
/// - If inventory full, pickup fails
///
/// # Pickup Process
///
/// 1. Player clicks item or walks over it with pet
/// 2. Client sends pickup request with object ID
/// 3. Server validates:
///    - Drop exists on current map
///    - Drop not expired
///    - Player is owner (or drop is free)
///    - Player is within range
///    - Player has inventory space (for items)
/// 4. Server gives item/mesos to player
/// 5. Server removes drop from map
/// 6. Server broadcasts pickup animation to map
///
/// # Anti-Cheat
///
/// - **Distance validation**: Must be within 150 units
/// - **Ownership validation**: Can't steal others' drops
/// - **Expiration validation**: Can't pick up expired drops
/// - **Damage cap validation**: Server validates damage (see combat handlers)
/// - **Inventory validation**: Can't pick up with full inventory
///
/// # Pet Auto-Loot
///
/// Pets can automatically pick up items:
/// - Pet must be summoned
/// - Pet must have Auto-Loot skill
/// - Pet follows pickup rules (distance, ownership, etc.)
/// - Multiple pets can loot simultaneously
///
/// # Broadcast
///
/// Pickup is broadcast to all players on map:
/// - Shows pickup animation (1)
/// - Removes drop from all clients
/// - Other players see item disappear
///
/// # Drop Display
///
/// Drops appear as sprites on the ground:
/// - Items show item icon
/// - Mesos show meso bag icon
/// - Player name shown above owned drops
/// - Expired drops fade out before disappearing
///
/// # Common Drop Sources
///
/// - **Mob drops**: When monsters are killed
/// - **Boss drops**: Rare items from boss fights
/// - **Player drops**: Items manually dropped
/// - **Meso drops**: Mesos dropped or dropped from mobs
/// - **Event drops**: Special event items
///
/// # Related Features
///
/// - **Item Drop**: Player drops items from inventory
/// - **Meso Drop**: Player drops mesos
/// - **Pet Loot**: Pets automatically loot drops
/// - **Vac Hack**: Attempts to loot from across map (detected by distance check)
public struct ItemPickupHandler: PacketHandler {

    public typealias Packet = MapleStory62.ItemPickupRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Look up the dropped item
        guard let mapItem = await MapItemRegistry.shared.drop(
            objectID: packet.objectID,
            on: character.currentMap
        ) else {
            return // Drop doesn't exist
        }

        // Check if expired
        if mapItem.isExpired {
            await MapItemRegistry.shared.removeDrop(objectID: packet.objectID, from: character.currentMap)
            return
        }

        // Check if player can pick up (owner check)
        guard mapItem.canPickUp(by: character.index) else {
            return // Not owner
        }

        // Check distance - player must be within 150 units of the drop
        let dropPosition = PlayerPosition(x: mapItem.position.x, y: mapItem.position.y)
        let inRange = await PlayerPositionRegistry.shared.isInRange(
            characterID: character.id,
            position: dropPosition,
            range: 150 // Maximum pickup distance
        )

        guard inRange else {
            return // Too far away
        }

        // Meso pickup
        if mapItem.itemID == 0 {
            character.meso = UInt32(min(Int64(character.meso) + Int64(mapItem.quantity), Int64(UInt32.max)))
            try await connection.database.insert(character)
        } else {
            // Item pickup
            let manipulator = InventoryManipulator()

            // Check if player has space
            guard try await manipulator.checkSpace(
                mapItem.itemID,
                quantity: UInt16(mapItem.quantity),
                for: character
            ) else {
                return // No inventory space
            }

            // Add to inventory
            try await manipulator.addFromDrop(
                mapItem.itemID,
                quantity: UInt16(mapItem.quantity),
                to: character
            )

            // Save character
            try await connection.database.insert(character)
        }

        // Remove from map
        await MapItemRegistry.shared.removeDrop(objectID: packet.objectID, from: character.currentMap)

        // Broadcast item removal to map
        try await connection.broadcast(RemoveItemFromMapNotification(
            animation: 1, // 1 = pickup animation
            objectID: packet.objectID
        ), map: character.currentMap)
    }
}
