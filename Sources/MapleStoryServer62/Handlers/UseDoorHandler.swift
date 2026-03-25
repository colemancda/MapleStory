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

/// Handles Mystic Door usage requests.
///
/// # Mystic Door System
///
/// The Mystic Door is a 4th job Priest skill (ID: 2311002) that creates a two-way portal
/// between a field map and the nearest town. Party members can freely use the door to
/// travel between the two locations.
///
/// # Packet Structure
///
/// ## UseDoorRequest (Client → Server)
/// - `objectID: UInt32` - Character ID of the door owner
/// - `mode: UInt8` - Direction: 0 = field → town, 1 = town → field
///
/// # Implementation Flow
///
/// ## Door Creation (SpecialMoveHandler)
/// When Priest casts Mystic Door:
/// 1. Validate skill (MP, cooldown)
/// 2. Find free door portal (type 6) in town
/// 3. Create Door object with:
///    - Owner ID
///    - Town map ID and portal ID
///    - Field map ID and position
///    - Duration (300s + level * 10s)
/// 4. Register in DoorRegistry
///
/// ## Door Usage (This Handler)
/// When player clicks door:
/// 1. Find door by owner ID in current map
/// 2. Validate door exists and not expired
/// 3. Validate access (owner or party member)
/// 4. Warp player:
///    - mode 0: Field → Town
///    - mode 1: Town → Field
///
/// # Access Control
///
/// A door can be used by:
/// - ✅ The door owner
/// - ✅ Members of the owner's party
/// - ❌ Random players (access denied)
///
/// # Door Expiration
///
/// Doors automatically expire after:
/// - Level 1: 300 seconds (5 minutes)
/// - Level 10: 400 seconds
/// - Level 20: 500 seconds
/// - Level 30: 600 seconds (10 minutes)
///
/// Expired doors are automatically removed from the registry.
///
/// # Error Handling
///
/// | Error | Message | Action |
/// |-------|---------|--------|
/// | Door not found | "That door has expired or doesn't exist." | Send enableActions |
/// | Door expired | "That door has expired." | Remove door, send enableActions |
/// | Access denied | "You cannot use this door." | Send enableActions |
/// | Invalid mode | - | Silently ignore |
///
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

        // Validate mode
        guard packet.mode == 0 || packet.mode == 1 else {
            return // Invalid mode
        }

        // Look up the door owner character by their index to get the UUID
        // The client sends Character.Index (UInt32), but Door stores Character.ID (UUID)
        let predicates: [Character.Predicate] = [
            .index(packet.objectID),
            .world(character.world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        guard let doorOwner = try await connection.database.fetch(Character.self, predicate: predicate, fetchLimit: 1).first else {
            // Door owner not found - door likely expired
            try await connection.send(ServerMessageNotification.notice(
                message: "That door has expired or doesn't exist."
            ))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Find the door by owner UUID in the current map
        guard let door = await DoorRegistry.shared.find(
            ownerID: doorOwner.id,
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
            await DoorRegistry.shared.remove(ownerID: doorOwner.id)
            try await connection.send(ServerMessageNotification.notice(
                message: "That door has expired."
            ))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        // Get player's party for access validation
        let party = await PartyRegistry.shared.party(for: character.id)

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
            // Warp to town at the door portal
            try await connection.warp(to: door.townMapID, spawn: door.townPortalID)
        } else {
            // Warp to field map
            // Note: Using spawn point 0 instead of exact door position
            // TODO: Set exact position after warping
            try await connection.warp(to: door.fieldMapID, spawn: 0)
        }

        // Log for debugging
        print("[Door] Character \(character.name) used door \(packet.objectID) " +
              "from \(door.fieldMapID) to \(door.townMapID), mode: \(packet.mode)")
    }
}
