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

        // TODO: Implement Phase 3 (Mob Drops & Map Items) first
        // This requires:
        // - MapItemRegistry to track dropped items
        // - MapItem struct with objectID, itemID, quantity, ownerID, position, expiry
        // - Drop system that creates map items on mob death

        // For now, this is a no-op until Phase 3 is implemented
        // When implemented:
        // 1. Look up MapItem by objectID
        // 2. Check if player is owner (or if ownerless)
        // 3. Check if player has inventory space
        // 4. Add item to player's inventory
        // 5. Remove map item from MapItemRegistry
        // 6. Broadcast item removal packet to map
    }
}
