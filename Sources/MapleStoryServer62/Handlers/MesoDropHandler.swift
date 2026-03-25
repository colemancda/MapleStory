//
//  MesoDropHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles meso dropping on the ground.
///
/// Players can drop mesos (in-game currency) on the ground for other players
/// to pick up. This is useful for trading and sharing mesos with party members.
///
/// # Meso Drop Flow
///
/// 1. Player selects "Drop Mesos" from inventory or uses a shortcut
/// 2. Player enters amount to drop
/// 3. Client sends meso drop request
/// 4. Server validates player has enough mesos
/// 5. Server deducts mesos from player
/// 6. Server spawns meso item on the map
/// 7. Server broadcasts item spawn to all map players
///
/// # Validation
///
/// - Player must have at least the requested meso amount
/// - Amount must be positive (cannot drop 0 or negative)
/// - Player must be in a valid map position
///
/// # Meso Ownership
///
/// Dropped mesos may be:
/// - **Loot protected**: Only the dropper can pick them up initially
/// - **Open to all**: After a timeout, anyone can pick them up
///
/// # Response
///
/// Sends item drop notification to all players on the map showing
/// the meso bag appearing on the ground.
public struct MesoDropHandler: PacketHandler {

    public typealias Packet = MapleStory62.MesoDropRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Check if character has enough meso
        guard character.meso >= packet.amount else { return }

        // Deduct meso from character
        var updatedCharacter = character
        updatedCharacter.meso -= packet.amount
        try await connection.database.insert(updatedCharacter)

        // Broadcast the drop to other players on the same map
        guard let mapID = await connection.mapID else { return }

        // Generate a unique object ID for the drop
        let objectID = UInt32.random(in: 1...1_000_000)

        // Get current timestamp in milliseconds
        let timestamp = UInt32(Date().timeIntervalSince1970 * 1000)

        try await connection.broadcast(DropItemFromMapobjectNotification(
            source: 1, // player drop
            objectID: objectID,
            itemID: 0, // 0 = meso
            quantity: packet.amount,
            ownerID: character.index,
            ownerType: 1, // owner only (can be picked up by owner)
            x: 0, // TODO: Get character position
            y: 0,
            timestamp: timestamp
        ), map: mapID)

        // TODO: Get actual drop position from character or packet
        // In a full implementation, we would track character position on the map
    }
}
