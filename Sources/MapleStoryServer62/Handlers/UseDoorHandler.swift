//
//  UseDoorHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseDoorHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseDoorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        guard packet.mode == 0 || packet.mode == 1 else {
            return // Invalid mode
        }

        // Find the door by owner ID in the current map
        guard let door = await DoorRegistry.shared.find(
            ownerID: packet.objectID,
            in: character.currentMap
        ) else {
            // Door doesn't exist in this map
            try await connection.send(ServerMessageNotification.notice(
                message: "That door has expired or doesn't exist."
            ))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Check if door has expired
        if door.isExpired {
            await DoorRegistry.shared.remove(ownerID: packet.objectID)
            try await connection.send(ServerMessageNotification.notice(
                message: "That door has expired."
            ))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Get player's party for access validation
        let party = try await connection.database.party(for: character.id)

        // Check if player can use this door (must be owner or in owner's party)
        guard door.canBeUsed(by: character.id, party: party) else {
            try await connection.send(ServerMessageNotification.notice(
                message: "You cannot use this door."
            ))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Warp player based on mode
        // mode == 0: Field → Town
        // mode == 1: Town → Field
        let toTown = packet.mode == 0

        if toTown {
            // Warp to town
            try await connection.warp(to: door.townMapID, spawn: door.townPortalID)
        } else {
            // Warp to field at door position
            // Note: We need to warp to the field and set position
            // For now, use spawn 0 (could be improved to set exact position)
            try await connection.warp(to: door.fieldMapID, spawn: 0)
        }

        // Log for debugging
        print("[Door] Character \(character.name) used door \(packet.objectID) " +
              "from \(door.fieldMapID) to \(door.townMapID), mode: \(packet.mode)")
    }
}
