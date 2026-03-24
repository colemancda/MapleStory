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

        // Check distance (player must be close to drop)
        // TODO: Implement distance check when player position is tracked

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

        // TODO: Broadcast item removal packet to map
        // Other players on the map need to see the item disappear
    }
}
