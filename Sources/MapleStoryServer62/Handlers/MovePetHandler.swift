//
//  MovePetHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles pet movement synchronization across players in a map.
///
/// When a player's pet moves, the client sends this packet so the server
/// can broadcast the pet's new position to other players on the same map.
/// This ensures all players see pets moving in sync.
///
/// # Pet Movement Flow
///
/// 1. Player's pet follows character movement
/// 2. Client sends move pet request with new position
/// 3. Server validates pet ownership
/// 4. Server updates pet position in PetRegistry
/// 5. Server broadcasts pet movement to all map players
///
/// # Pet Slots
///
/// Characters can have up to 3 active pets simultaneously (slots 0-2).
/// The slot determines display order and which pet is shown first.
///
/// # Broadcasting
///
/// Sends `MovePetNotification` to all players on the current map with:
/// - **characterID**: Owner's character ID
/// - **slot**: Pet slot (0, 1, or 2)
/// - **petID**: Unique pet identifier
/// - **movementData**: Movement path data
public struct MovePetHandler: PacketHandler {

    public typealias Packet = MapleStory62.MovePetRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        let petID = PetID(packet.petID)
        guard let spawnedPet = await PetRegistry.shared.spawnedPet(petID),
              spawnedPet.ownerID == character.id else {
            return
        }

        await PetRegistry.shared.updatePetPosition(
            petID,
            position: PetPosition(x: packet.startX, y: packet.startY)
        )

        guard let slot = await PetRegistry.shared.activeSlot(for: petID, ownerID: character.id) else {
            return
        }

        try await connection.broadcast(
            MovePetNotification(
                characterID: character.index,
                slot: slot,
                petID: packet.petID,
                movementData: []
            ),
            map: mapID
        )
    }
}
