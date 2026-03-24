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
