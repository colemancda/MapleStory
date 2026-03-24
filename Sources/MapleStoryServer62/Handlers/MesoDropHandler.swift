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
